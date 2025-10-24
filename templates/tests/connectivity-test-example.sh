#!/bin/bash
# Connectivity Test Suite - Cloud Migration Toolkit
# Tests network connectivity after migration to cloud-native architecture

set -euo pipefail

# Configuration
PROJECT_ID="${CLOUD_PROJECT:-your-project-id}"
REGION="${CLOUD_REGION:-us-central1}"
BASTION_NAME="${BASTION_NAME:-bastion-host}"
TEST_TIMEOUT=10

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
SKIPPED=0

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAILED++))
}

test_skip() {
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
    ((SKIPPED++))
}

# Test Suite
echo "========================================="
echo " Cloud Network Migration - Test Suite"
echo "========================================="
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "Date: $(date)"
echo "========================================="
echo

# Test 1: External Load Balancer HTTPS Connectivity
test_external_lb() {
    local lb_name=$1
    local lb_ip=$2

    echo -n "Test: External LB ($lb_name) HTTPS connectivity... "

    # Get HTTP status code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TEST_TIMEOUT "https://$lb_ip" 2>/dev/null || echo "000")

    if [[ "$http_code" == "200" ]] || [[ "$http_code" == "301" ]] || [[ "$http_code" == "302" ]]; then
        test_pass "External LB $lb_name (HTTP $http_code)"
    else
        test_fail "External LB $lb_name returned HTTP $http_code (expected 200/301/302)"
    fi
}

# Test 2: IAP SSH Access to Bastion
test_iap_ssh() {
    echo -n "Test: IAP SSH access to bastion... "

    # Attempt to SSH via IAP and run a simple command
    if gcloud compute ssh "$BASTION_NAME" \
        --project="$PROJECT_ID" \
        --zone="${REGION}-a" \
        --tunnel-through-iap \
        --command="echo success" \
        2>/dev/null | grep -q "success"; then
        test_pass "IAP SSH to $BASTION_NAME"
    else
        test_fail "IAP SSH to $BASTION_NAME failed (check IAM permissions and bastion existence)"
    fi
}

# Test 3: East-West Traffic (Spoke → Hub ILB → Spoke)
test_east_west() {
    local source_instance=$1
    local hub_ilb_ip=$2
    local expected_response=$3

    echo -n "Test: East-west traffic ($source_instance → hub ILB $hub_ilb_ip)... "

    # SSH to source instance and curl hub internal LB
    response=$(gcloud compute ssh "$source_instance" \
        --project="$PROJECT_ID" \
        --zone="${REGION}-a" \
        --tunnel-through-iap \
        --command="curl -s --max-time $TEST_TIMEOUT http://$hub_ilb_ip" \
        2>/dev/null || echo "ERROR")

    if echo "$response" | grep -q "$expected_response"; then
        test_pass "East-west traffic to hub ILB $hub_ilb_ip"
    else
        test_fail "East-west traffic failed (expected '$expected_response', got '$response')"
    fi
}

# Test 4: Egress Connectivity (SaaS Services)
test_egress_saas() {
    local instance_name=$1
    local saas_endpoint=$2
    local port=$3

    echo -n "Test: Egress to SaaS ($saas_endpoint:$port from $instance_name)... "

    # SSH to instance and test connectivity
    if gcloud compute ssh "$instance_name" \
        --project="$PROJECT_ID" \
        --zone="${REGION}-a" \
        --tunnel-through-iap \
        --command="timeout $TEST_TIMEOUT nc -zv $saas_endpoint $port 2>&1" \
        2>/dev/null | grep -q "succeeded"; then
        test_pass "Egress to $saas_endpoint:$port"
    else
        test_fail "Egress to $saas_endpoint:$port failed (check Cloud NAT and firewall rules)"
    fi
}

# Test 5: Database Isolation (Negative Test - Should FAIL)
test_database_isolation() {
    local db_instance=$1

    echo -n "Test: Database isolation (internet egress should FAIL)... "

    # Attempt to reach internet from database instance (should timeout)
    if gcloud compute ssh "$db_instance" \
        --project="$PROJECT_ID" \
        --zone="${REGION}-a" \
        --tunnel-through-iap \
        --command="timeout 5 curl -s https://google.com" \
        2>/dev/null | grep -q "google"; then
        test_fail "Database VPC has internet access (SECURITY ISSUE!)"
    else
        test_pass "Database VPC correctly isolated (no internet route)"
    fi
}

# Test 6: Firewall Deny Rule Logging
test_firewall_deny_logging() {
    local blocked_endpoint=$1

    echo -n "Test: Firewall deny rule for $blocked_endpoint... "

    # Attempt to reach blocked endpoint (should fail)
    gcloud compute ssh "$BASTION_NAME" \
        --project="$PROJECT_ID" \
        --zone="${REGION}-a" \
        --tunnel-through-iap \
        --command="timeout 5 curl -s $blocked_endpoint" \
        2>/dev/null || true

    # Check if deny log appeared in Cloud Logging (within last 2 minutes)
    log_count=$(gcloud logging read \
        "resource.type=gce_subnetwork AND jsonPayload.disposition=DENIED" \
        --project="$PROJECT_ID" \
        --limit=10 \
        --format=json \
        --freshness=2m \
        2>/dev/null | grep -c "$blocked_endpoint" || echo "0")

    if [[ "$log_count" -gt 0 ]]; then
        test_pass "Firewall deny rule logged for $blocked_endpoint"
    else
        test_warn "Firewall deny log not found (may take a few minutes to appear)"
        test_skip "Deny logging for $blocked_endpoint"
    fi
}

# Run Tests
echo "========================================="
echo " Running Tests"
echo "========================================="
echo

# Example test invocations (customize for your environment)

# Test 1: External Load Balancers
# Uncomment and customize with your actual LB IPs
# test_external_lb "lb-app" "34.120.45.67"
# test_external_lb "lb-web" "34.120.45.68"

# Test 2: IAP SSH Access
test_iap_ssh

# Test 3: East-West Traffic
# Uncomment and customize
# test_east_west "app-instance" "10.0.0.10" "success"

# Test 4: Egress Connectivity
# Uncomment and customize with your actual SaaS endpoints
# test_egress_saas "app-instance" "smtp.sendgrid.net" 2525
# test_egress_saas "app-instance" "api.stripe.com" 443

# Test 5: Database Isolation (Critical Security Test)
# Uncomment and customize
# test_database_isolation "db-instance"

# Test 6: Firewall Deny Rule
# Uncomment and customize
# test_firewall_deny_logging "https://blocked-endpoint.example.com"

# Summary
echo
echo "========================================="
echo " Test Results"
echo "========================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo "Total: $((PASSED + FAILED + SKIPPED))"
echo "========================================="

# Exit with error if any tests failed
if [[ $FAILED -gt 0 ]]; then
    log_error "Some tests failed. Review failures above."
    exit 1
else
    log_info "All tests passed!"
    exit 0
fi
