# Cloud Network Migration AI Agent Toolkit

## Master Guide: From Legacy Firewall to Cloud-Native Architecture

**Version:** 1.0
**Last Updated:** 2025
**Purpose:** Complete guide for migrating from appliance-based network security to cloud-native solutions using AI agents

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Migration Challenge](#the-migration-challenge)
3. [Solution Architecture](#solution-architecture)
4. [AI Agent Role](#ai-agent-role)
5. [Implementation Methodology](#implementation-methodology)
6. [Phase-by-Phase Guide](#phase-by-phase-guide)
7. [AI Agent Prompts & Tasks](#ai-agent-prompts--tasks)
8. [Validation & Testing](#validation--testing)
9. [Rollback Procedures](#rollback-procedures)
10. [Post-Migration Optimization](#post-migration-optimization)

---

## Executive Summary

### What This Guide Provides

This toolkit enables organizations to:

1. **Migrate from appliance-based firewalls** (e.g., Palo Alto, Fortinet, Checkpoint) **to cloud-native security** (GCP, AWS, Azure)
2. **Leverage AI agents** to automate configuration mapping, infrastructure generation, and validation
3. **Reduce migration time** from months to weeks through intelligent automation
4. **Minimize human error** with AI-powered validation and compliance checking
5. **Maintain or improve security posture** throughout the transition

### Key Benefits

- **Cost Reduction:** 30-50% savings on firewall licensing and operational overhead
- **Improved Reliability:** Cloud-native SLAs (99.99%+) vs. manual appliance failover
- **Enhanced Security:** Zero-trust access, architecture-enforced isolation
- **Faster Iteration:** Infrastructure-as-Code enables rapid changes
- **Better Visibility:** Centralized logging and real-time monitoring

### Migration Timeline

Typical migration timeline: **8-12 weeks**

```
Week 1-2:  Foundation (VPC architecture, management access)
Week 3-4:  Core services (application VPCs, load balancers)
Week 5-6:  Data tier (database isolation, private endpoints)
Week 7-8:  Validation & testing (parallel run)
Week 9-10: Cutover & stabilization
Week 11-12: Optimization & decommission
```

---

## The Migration Challenge

### Common Scenario

Most organizations face this architecture:

```
Internet
    ↓
External Load Balancer
    ↓
Appliance Firewall (Palo Alto / Fortinet / Checkpoint)
    │
    ├─ Untrust Zone (Internet-facing)
    ├─ Trust Zone (Internal services)
    ├─ DMZ (Application tier)
    └─ Database Zone (Data tier)
    ↓
Multiple VPC Networks (isolated workloads)
```

### Key Pain Points

| Challenge | Impact | AI Agent Solution |
|-----------|--------|-------------------|
| **Complex rule sets** | 1000+ firewall rules to migrate | Automated parsing and mapping |
| **NAT configuration** | Manual port forwarding for each service | Auto-generate load balancer configs |
| **Egress dependencies** | SaaS allow-lists scattered across rules | Consolidate and validate connectivity |
| **Zero-downtime requirement** | Cannot disrupt production | Parallel environment testing |
| **Compliance validation** | Must prove equivalent security | Automated compliance checks |
| **Knowledge transfer** | Team must learn new architecture | AI-generated documentation |

### Why Traditional Approaches Fail

1. **Manual mapping is error-prone:** Firewall exports contain thousands of lines; humans miss critical rules
2. **Testing is incomplete:** Hard to validate all traffic paths without production load
3. **Documentation lags:** Engineers focus on implementation, not docs
4. **Rollback is risky:** No clear path back if issues arise

### How AI Agents Help

AI agents excel at:

- **Pattern recognition:** Identify rule dependencies and traffic flows
- **Code generation:** Produce Infrastructure-as-Code (Terraform, Pulumi) from firewall configs
- **Validation:** Simulate connectivity and detect misconfigurations
- **Documentation:** Auto-generate network diagrams and runbooks

---

## Solution Architecture

### Target Cloud-Native Design

The migration target is a **hub-and-spoke VPC architecture** with dedicated VPCs for different functions:

```
┌─────────────────────────────────────────────────────┐
│ Management VPC (Bastion & Admin Access)             │
│ → IAP-based access, NO internet egress              │
│ → VPN gateway for on-prem connectivity              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Hub VPC (East-West Traffic Only)                    │
│ → Internal load balancers for inter-VPC routing     │
│ → Shared services (DNS, monitoring)                 │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Egress Proxy VPC (Centralized Internet Egress)      │
│ → Cloud NAT with single egress IP                   │
│ → Optional: Forward proxy for L7 inspection         │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Shared Services VPC (Private Endpoints)             │
│ → Private Service Connect for artifact repos        │
│ → Security tooling endpoints (no internet)          │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Spoke VPCs (Workload Isolation)                     │
│ → Application VPC: Web/API services                 │
│ → Database VPC: NO internet route (enforced)        │
│ → Supporting VPCs: CI/CD, monitoring, etc.          │
└─────────────────────────────────────────────────────┘
```

### Design Principles

#### 1. Separation of Concerns

Each VPC has a single, well-defined purpose:

- **Management VPC:** Admin access only (bastion hosts, VPN)
- **Hub VPC:** East-west routing only (no internet, no workloads)
- **Egress VPC:** Internet egress only (NAT gateway, optional proxy)
- **Spoke VPCs:** Workloads only (no shared infrastructure)

#### 2. Architecture-Enforced Security

Security is built into the network design, not just firewall rules:

- **Database VPC has NO peering to egress VPC** → Impossible to reach internet, even with misconfigured rules
- **Non-transitive peering** → Spoke VPCs cannot talk directly (must go through hub)
- **Single egress point** → All internet traffic funnels through one VPC for centralized logging

#### 3. Defense in Depth

Multiple security layers:

```
Layer 1: Cloud Armor (DDoS, WAF, geo-blocking)
Layer 2: External HTTPS Load Balancer (SSL termination)
Layer 3: VPC Firewall Rules (network-level filtering)
Layer 4: Hierarchical Policies (org-level enforcement, cannot be overridden)
Layer 5: IAP + OS Login (zero-trust admin access)
Layer 6: Service Account Binding (workload identity, no tag spoofing)
```

#### 4. Centralized Egress

All spoke VPCs route internet-bound traffic to the **Egress VPC**:

- **Single static IP** (or small pool) for all workloads
- Simplifies SaaS vendor allow-listing (e.g., SendGrid, payment gateways)
- Centralized VPC Flow Logs and firewall logs
- Future: Can add forward proxy (Squid, Zscaler) for L7 visibility

**Exception:** Database VPC has **no egress peering** (isolation enforced)

---

## AI Agent Role

### How AI Agents Accelerate Migration

AI agents act as **intelligent assistants** that:

1. **Analyze existing configurations** (firewall exports, network inventories)
2. **Generate Infrastructure-as-Code** (Terraform modules for VPCs, firewalls, load balancers)
3. **Validate connectivity** (simulate traffic flows, detect misconfigurations)
4. **Create documentation** (network diagrams, runbooks, security assessments)
5. **Monitor migration** (compare logs between old and new environments)

### Agent Capabilities Matrix

| Task Category | Example Tasks | AI Contribution |
|---------------|---------------|-----------------|
| **Configuration Translation** | Parse firewall XML/JSON exports | Extract rules, NAT mappings, address groups |
| **Infrastructure Generation** | Generate Terraform code for VPCs | Auto-create modules based on best practices |
| **Security Mapping** | Map firewall zones to cloud security groups | Ensure rule parity, flag gaps |
| **Load Balancer Setup** | Convert NAT rules to cloud LB configs | Generate backend NEGs, health checks |
| **Testing & Validation** | Create connectivity test suites | Automated negative tests (verify denies work) |
| **Documentation** | Generate network diagrams | Mermaid/draw.io diagrams from config |
| **Log Analysis** | Compare firewall logs vs cloud logs | Identify traffic pattern differences |
| **Compliance Checking** | Validate no unintended internet routes | Policy Analyzer, automated audits |

### Recommended Agent Workflow

```
Phase Start
    ↓
Agent reads requirements + existing config
    ↓
Agent generates Infrastructure-as-Code
    ↓
Human review + approval
    ↓
Agent executes deployment (or human runs terraform apply)
    ↓
Agent runs validation tests
    ↓
Agent generates report (pass/fail, recommendations)
    ↓
If issues: Agent suggests fixes → Human review
If success: Move to next phase
```

### AI Agent Prompt Structure

Each phase has specific prompts. Example for Phase 1:

```markdown
Agent Task: "Create foundation VPCs with Terraform"

Input:
  - Network topology requirements (hub-and-spoke design)
  - CIDR allocations (management: 10.0.5.0/24, hub: 10.0.0.0/20, etc.)
  - Security requirements (IAP for bastion, no internet from mgmt)

Output:
  - Terraform modules for vpc-mgmt, vpc-hub, vpc-egress, vpc-shared
  - Firewall rules for IAP access to bastion
  - Cloud NAT configuration with logging enabled
  - Validation tests:
    - IAP tunnel to bastion succeeds
    - No internet route from management VPC
    - Cloud NAT logs appear in Cloud Logging
```

See [AI Agent Prompts](./prompts/) folder for complete prompt templates.

---

## Implementation Methodology

### Core Principles

1. **Read-Only on Production:** AI agents NEVER modify existing environments; they only read configs and generate new infrastructure
2. **Separate Shadow Environment:** All testing occurs in isolated project/account
3. **Parallel Run:** Old and new environments run side-by-side before cutover
4. **Incremental Validation:** Each phase has pass/fail criteria before proceeding
5. **Automated Rollback:** Pre-defined rollback procedures with <2 hour recovery time

### Prerequisites

Before starting migration:

**Technical:**
- [ ] Firewall configuration export (XML, JSON, or API access)
- [ ] Network inventory (VPCs, subnets, IP ranges)
- [ ] Service catalog (list of all external services and ports)
- [ ] Current network diagrams
- [ ] Access to cloud provider account/project
- [ ] Terraform or equivalent IaC tool installed

**Organizational:**
- [ ] Executive sponsorship and budget approval
- [ ] Dedicated team (1 network engineer, 1 security engineer, 1 DevOps, AI agent access)
- [ ] Change control approval for shadow environment
- [ ] Communication plan for cutover window

**AI Agent Setup:**
- [ ] API access to AI agent (Claude, GPT-4, etc.)
- [ ] Agent authorized to read firewall configs (API keys, exports)
- [ ] Agent has example templates and best practices loaded
- [ ] Test run completed on sample firewall export

### Success Criteria (Before Cutover)

| Metric | Target | Validation Method |
|--------|--------|-------------------|
| **Health Check Success Rate** | 100% | Cloud Monitoring dashboard |
| **Connectivity Tests** | All pass | Automated test suite (curl, gcloud) |
| **Security Tests** | All denies work | Negative tests (attempt blocked traffic) |
| **Latency vs. Legacy** | <10% increase | Comparative analysis (p50, p95, p99) |
| **Packet Loss** | 0% | Continuous ping tests |
| **Log Parity** | 100% | Side-by-side log comparison |
| **Compliance Audit** | Pass | Automated policy checks (e.g., no internet from DB) |

---

## Phase-by-Phase Guide

### Phase 1: Foundation (Week 1-2)

**Goal:** Establish core VPC architecture and secure admin access

**Tasks:**

1. **Create shadow project/account** (e.g., `company-network-shadow`)
2. **Enable required cloud APIs** (Compute, VPC, Cloud NAT, IAP, Logging)
3. **Deploy Management VPC**
   - Subnets: bastion (10.0.5.0/27), VPN (10.0.5.32/27), automation (10.0.5.64/27)
   - Firewall rules: Allow IAP (35.235.240.0/20 → bastion), deny internet
   - IAP configuration: Enable OS Login, grant roles/iap.tunnelResourceAccessor
4. **Deploy Hub VPC**
   - Subnets: internal LB (10.0.0.0/25), shared services (10.0.0.128/25)
   - No internet route, no Cloud NAT
5. **Deploy Egress Proxy VPC**
   - Subnets: NAT gateway (10.0.4.0/25), optional proxy VMs (10.0.4.128/25)
   - Cloud NAT: Reserve static egress IP, enable logging
   - Default route: 0.0.0.0/0 → Internet Gateway
6. **Deploy Shared Services VPC**
   - Subnets: private endpoints (10.1.0.0/25), artifact services (10.1.0.128/25)
   - Configure Private Service Connect endpoints (artifact repos, security tools)
7. **Establish VPC peering**
   - Management ↔ Hub (admin access to all spokes via hub)
   - Hub ↔ Egress (no routes imported, just for future use)
   - Shared ↔ Hub (for spoke access to private endpoints)

**AI Agent Tasks:**

```markdown
Agent Task 1: "Generate Terraform for foundation VPCs"
Input: Network topology diagram, CIDR allocations, security requirements
Output:
  - Terraform modules for 4 VPCs (management, hub, egress, shared)
  - Firewall rules (IAP access, deny internet from management)
  - Cloud NAT configuration with static IP
  - VPC peering configurations
  - Validation tests (IAP connectivity, NAT logs, no internet from mgmt)

Agent Task 2: "Validate IAP access to bastion"
Input: Bastion VM details, IAM policy
Output:
  - Step-by-step test procedure (gcloud compute ssh with --tunnel-through-iap)
  - Expected results (successful SSH, logs in Cloud Logging)
  - Troubleshooting guide if access fails
```

**Validation Checklist:**

- [ ] IAP tunnel to bastion succeeds (`gcloud compute ssh bastion --tunnel-through-iap`)
- [ ] No default route to internet in management VPC (`gcloud compute routes list`)
- [ ] Cloud NAT logs appear in Cloud Logging
- [ ] VPC peering routes imported correctly

**Expected Duration:** 3-5 days

---

### Phase 2: Core Spoke VPCs (Week 3-4)

**Goal:** Migrate application workloads to new VPCs with external load balancers

**Tasks:**

1. **Create Application VPC** (e.g., `vpc-app`)
   - Subnets: Preserve existing CIDRs (e.g., 10.10.0.0/22 for nodes, 10.96.0.0/20 for GKE pods)
   - VPC peering: app ↔ hub, app ↔ egress, app ↔ management
   - Firewall rules:
     - Ingress: Health checks (35.191.0.0/16, 130.211.0.0/22 → backends)
     - Ingress: Hub ILB (10.0.0.0/25 → backends)
     - Ingress: Management SSH (10.0.5.0/27 → SSH targets)
     - Egress: SaaS allow-list (e.g., SendGrid TCP 2525, payment gateways)
     - Egress: Google APIs (199.36.153.8/30 → TCP 443)
     - Deny: Block-listed endpoints (e.g., suspicious SMS gateways)
   - Custom route: 0.0.0.0/0 → VPC peering to egress VPC (for internet access)

2. **Map legacy NAT rules to cloud load balancers**
   - AI agent parses firewall export (NAT section)
   - For each NAT rule:
     ```
     Legacy: External LB port 50000 → Firewall NAT → Internal service 10.10.0.18:443
     New: External HTTPS LB → Backend NEG (10.10.0.18:443 in vpc-app)
     ```
   - Create Network Endpoint Groups (NEGs) for each backend service
   - Create External HTTPS Load Balancers with:
     - SSL certificate (Google-managed, auto-renewal)
     - Backend service (NEG + health check)
     - URL map (routing rules)
     - Cloud Armor policy (optional: rate limiting, geo-blocking)

3. **Create internal load balancers in Hub VPC**
   - For east-west traffic (spoke ↔ spoke via hub)
   - Internal passthrough LB (Layer 4)
   - VIP in hub subnet (e.g., 10.0.0.10)
   - Backend: NEG in app VPC

4. **Deploy Web VPC** (repeat above for frontend services)

**AI Agent Tasks:**

```markdown
Agent Task 1: "Map firewall NAT rules to GCP External LBs"
Input: Firewall export (NAT section), existing cloud forwarding rules
Output:
  - List of all external LBs required (name, frontend port, backend IP:port)
  - Terraform code for each LB:
    - google_compute_global_address (reserve IP)
    - google_compute_backend_service (NEG, health check)
    - google_compute_url_map (routing rules)
    - google_compute_target_https_proxy (SSL cert)
    - google_compute_global_forwarding_rule (frontend)
  - Health check configurations (protocol: HTTPS, path: /healthz, interval: 5s)
  - SSL certificate definitions (Google-managed)

Agent Task 2: "Generate firewall rules for app VPC"
Input: Firewall export (security rules), app VPC requirements
Output:
  - Terraform code for VPC firewall rules:
    - app-ing-health-checks (allow 35.191.0.0/16, 130.211.0.0/22 → tag:app-backend)
    - app-ing-from-hub (allow 10.0.0.0/25 → tag:app-backend on TCP 443)
    - app-eg-sendgrid (allow tag:app-email → smtp.sendgrid.net on TCP 2525)
    - app-eg-payment (allow tag:app-payment → payment-gateway-ips on TCP 7225)
    - app-deny-sms (DENY tag:app → blocked-sms-api)
    - default-deny-log (deny all with logging enabled)
  - Address group definitions (FQDN-based for SaaS services)
```

**Validation Checklist:**

- [ ] External LB health checks green (all backends healthy)
- [ ] Traffic flows: External LB → Backend NEG (`curl https://<lb-ip>`)
- [ ] Egress traffic routes through Cloud NAT (check VPC Flow Logs)
- [ ] SaaS connectivity works (e.g., SendGrid test email)
- [ ] Deny rules trigger (attempt blocked endpoint, verify log entry)
- [ ] East-west traffic works (app → hub ILB → web)

**Expected Duration:** 5-7 days

---

### Phase 3: Database VPC & Isolation (Week 5-6)

**Goal:** Migrate database workloads with architecture-enforced internet isolation

**Critical Design:** Database VPC has **NO peering to egress VPC** (no internet route possible)

**Tasks:**

1. **Create Database VPC** (e.g., `vpc-db`)
   - Subnets: Database cluster (10.2.0.0/24), replicas (10.2.1.0/24)
   - VPC peering: db ↔ hub (internal LB access), db ↔ shared (private endpoints), db ↔ management (admin SSH)
   - **NO peering to egress VPC** (cannot reach internet)
   - Firewall rules:
     - Ingress: Application traffic (10.10.0.0/22, 10.96.0.0/20 → tag:database on TCP 27017-27019)
     - Ingress: Management admin (10.0.5.0/27 → tag:db-admin on TCP 22, 28031-28033)
     - Egress: Shared services via PSC (10.1.0.0/25 → TCP 443 for artifact repos, security tools)
     - Deny: Internet (0.0.0.0/0 → DENY with logging, catches misconfiguration attempts)

2. **Configure Private Service Connect endpoints in Shared VPC**
   - Artifact repositories (e.g., JFrog, Google Artifact Registry)
   - Security tooling (e.g., CrowdStrike sensor updates, vulnerability scanners)
   - No internet traversal required

3. **Automated compliance test: Verify NO internet route**
   ```bash
   # Test script: Attempt to reach internet from DB VPC (must fail)
   gcloud compute ssh db-instance --tunnel-through-iap --command="curl -m 5 https://google.com"
   # Expected: Timeout or DNS failure (no route)

   # Verify no route to 0.0.0.0/0 exists
   gcloud compute routes list --filter="network:vpc-db AND destRange:0.0.0.0/0"
   # Expected: Empty result
   ```

4. **Create remaining spoke VPCs** (marketing, CI/CD, monitoring, etc.)
   - Follow same pattern as app VPC
   - Peer with hub, egress, management
   - Apply hierarchical policies

5. **Deploy Hierarchical Firewall Policies** (organization/folder level)
   - Enforced across all VPCs, cannot be overridden by project admins
   - Rules:
     ```
     Priority 100: org-allow-health-checks (35.191.0.0/16, 130.211.0.0/22 → tag:allow-hc)
     Priority 200: org-allow-google-apis (tag:needs-google-apis → 199.36.153.8/30)
     Priority 300: org-deny-blocked-endpoints (tag:* → blocked-list → DENY)
     Priority 9998: org-log-all-denies (all → all → DENY with logging)
     ```

**AI Agent Tasks:**

```markdown
Agent Task 1: "Create MongoDB isolation architecture"
Input: Database security requirements, shared services list
Output:
  - Terraform for vpc-db (subnets, NO egress peering)
  - VPC peering configs (db ↔ hub, db ↔ shared, db ↔ management)
  - Firewall rules (allow app traffic, allow PSC to shared, DENY internet)
  - Private Service Connect endpoint configs in vpc-shared
  - Automated compliance test script (verify no internet route, test PSC connectivity)
  - Documentation: Network diagram showing isolation

Agent Task 2: "Deploy hierarchical firewall policies"
Input: Firewall export (organization-level rules), cloud org structure
Output:
  - Hierarchical policy YAML/Terraform
  - Rules:
    - org-allow-health-checks (cannot be overridden)
    - org-allow-google-apis (standard for all workloads)
    - org-deny-blocked-endpoints (enforced block-list)
    - org-log-all-denies (forensics, compliance)
  - Service account targeting (prevent tag spoofing)
  - Logging configuration (export to SIEM)
```

**Validation Checklist:**

- [ ] Database can reach artifact repo via PSC (e.g., `curl https://artifactory.internal`)
- [ ] Database **cannot** reach internet (`curl https://google.com` must timeout)
- [ ] No route to 0.0.0.0/0 exists in database VPC
- [ ] Admin access from bastion works (`ssh via IAP`)
- [ ] All deny rules log to Cloud Logging
- [ ] Hierarchical policies applied correctly (gcloud org-policies list)

**Expected Duration:** 5-7 days

---

### Phase 4: Validation & Testing (Week 7-8)

**Goal:** Comprehensive testing before cutover

**Test Categories:**

#### 1. Connectivity Tests

**External → Service Tests:**
```bash
# Test each external LB endpoint
for lb in lb-app lb-web lb-api; do
  echo "Testing $lb..."
  curl -I https://$lb.example.com
  # Expected: HTTP 200 OK
done
```

**Spoke → Hub ILB → Spoke (East-West) Tests:**
```bash
# From app VPC, reach web VPC via hub internal LB
gcloud compute ssh app-instance --tunnel-through-iap --command="curl http://10.0.0.20:443"
# Expected: Web service response
```

**Bastion → Workload SSH Tests:**
```bash
# SSH to app instance via IAP
gcloud compute ssh app-instance --tunnel-through-iap
# Expected: Successful login
```

#### 2. Egress Tests

**SaaS Connectivity:**
```bash
# SendGrid test
gcloud compute ssh app-instance --tunnel-through-iap --command="telnet smtp.sendgrid.net 2525"
# Expected: Connected

# Payment gateway test
gcloud compute ssh app-instance --tunnel-through-iap --command="curl https://payment-gateway.example.com/health"
# Expected: HTTP 200 OK
```

**Google APIs via Private Google Access:**
```bash
gcloud compute ssh app-instance --tunnel-through-iap --command="curl https://storage.googleapis.com"
# Expected: HTTP 200 OK (via Private Access, no NAT)
```

**Deny Rule Tests:**
```bash
# Attempt blocked endpoint
gcloud compute ssh app-instance --tunnel-through-iap --command="curl -m 5 https://blocked-endpoint.example.com"
# Expected: Timeout or connection refused

# Verify deny log appeared
gcloud logging read "resource.type=gce_subnetwork AND jsonPayload.disposition=DENIED" \
  --limit=10 --format=json
# Expected: Log entry with destination=blocked-endpoint.example.com
```

#### 3. Security Tests (Negative Tests)

**Attempt internet egress from database VPC (must fail):**
```bash
gcloud compute ssh db-instance --tunnel-through-iap --command="curl -m 5 https://google.com"
# Expected: Timeout (no route to internet)
```

**Attempt cross-spoke traffic without hub (must fail):**
```bash
# From app VPC, attempt direct connection to web VPC IP
gcloud compute ssh app-instance --tunnel-through-iap --command="curl http://10.30.0.10:443"
# Expected: Timeout (no direct route, must go through hub)
```

**IAP access without IAM role (must fail):**
```bash
# As user without roles/iap.tunnelResourceAccessor
gcloud compute ssh app-instance --tunnel-through-iap
# Expected: Permission denied
```

#### 4. Performance Tests

**Latency Comparison:**
```bash
# Measure latency old vs new
# Old (via legacy firewall):
curl -w "@curl-format.txt" -o /dev/null -s https://old-lb.example.com/api/health

# New (cloud-native):
curl -w "@curl-format.txt" -o /dev/null -s https://new-lb.example.com/api/health

# Compare p50, p95, p99 latencies
# Target: <10% increase
```

**Throughput Test:**
```bash
# Use tool like Apache Bench or wrk
ab -n 1000 -c 10 https://new-lb.example.com/
# Compare requests/second to legacy baseline
```

**AI Agent Tasks:**

```markdown
Agent Task 1: "Generate automated test suite"
Input: Network topology, security requirements, service catalog
Output:
  - Connectivity test scripts (bash/Python using gcloud, curl)
  - Security negative tests (verify denies work, no unintended routes)
  - Performance benchmarking scripts (latency, throughput)
  - Test report template (Markdown with pass/fail results)
  - CI/CD integration (run tests on every infrastructure change)

Agent Task 2: "Analyze logs for discrepancies"
Input: VPC Flow Logs, Firewall Logs, Legacy firewall logs
Output:
  - Side-by-side comparison of allow/deny decisions (legacy vs cloud)
  - Latency comparison (p50, p95, p99)
  - Anomaly detection (unexpected traffic, new connections)
  - Recommendations for firewall tuning (overly permissive rules, missing allows)
```

**Validation Checklist:**

- [ ] All connectivity tests pass (100% success rate)
- [ ] All egress tests pass (SaaS reachable, denies enforced)
- [ ] All security tests pass (negative tests fail as expected)
- [ ] Performance within tolerance (<10% latency increase)
- [ ] Zero packet loss on test traffic
- [ ] Logs show correct allow/deny decisions

**Expected Duration:** 5-7 days

---

### Phase 5: Parallel Run (Week 9-10)

**Goal:** Run old and new environments side-by-side, validate before cutover

**Tasks:**

1. **Route test traffic to shadow environment**
   - Split DNS: Route 10% of traffic to new LBs
   - Use separate test domain (e.g., `new.example.com`)
   - Monitor both environments simultaneously

2. **Side-by-side log comparison**
   - Export legacy firewall logs and cloud logs to same SIEM
   - Compare allow/deny decisions for identical traffic
   - Flag discrepancies (e.g., legacy allowed but cloud denied)

3. **Performance monitoring**
   - Metrics to compare:
     - Connection success rate
     - Latency (p50, p95, p99)
     - Error rate (4xx, 5xx)
     - Egress traffic patterns (bandwidth, destinations)
     - Firewall deny rate (should match legacy)

4. **Tune firewall rules as needed**
   - If legacy allowed traffic that cloud denies → Investigate and fix
   - If cloud allows traffic that legacy denied → Tighten rules
   - Update address groups (FQDNs may resolve to new IPs)

**AI Agent Tasks:**

```markdown
Agent Task: "Monitor parallel run and detect anomalies"
Input: Real-time logs from both environments (legacy firewall + cloud)
Output:
  - Hourly comparison reports (Markdown/HTML dashboard)
  - Alerts on discrepancies:
    - Connection failures (legacy succeeded, cloud failed)
    - Latency spikes (cloud >20% slower than legacy)
    - New deny rules triggering (unexpected traffic blocked)
  - Root cause analysis for failures (which rule caused issue, suggested fix)
  - Go/no-go recommendation for cutover (pass/fail criteria met?)
```

**Go/No-Go Criteria for Cutover:**

| Metric | Threshold | Status |
|--------|-----------|--------|
| Connection success rate | >99.9% | Pass/Fail |
| Latency difference | <10% | Pass/Fail |
| Packet loss | 0% | Pass/Fail |
| Security policy parity | 100% (no unintended allows) | Pass/Fail |
| Approval from stakeholders | Security, Network, DevOps teams | Pass/Fail |

**Expected Duration:** 7-10 days

---

### Phase 6: Cutover & Stabilization (Week 11-12)

**Goal:** Switch production traffic to new environment, decommission legacy

**Cutover Procedure:**

1. **Freeze legacy firewall changes** (export final config for reference)
2. **Update external DNS** to point to new load balancer IPs
   - Use short TTL (60s) for quick rollback if needed
   - Monitor DNS propagation (`dig @8.8.8.8 example.com`)
3. **Monitor traffic shift** (VPC Flow Logs, LB metrics)
   - Watch for errors, latency spikes
   - Have rollback plan ready (<2 hour recovery)
4. **24-48 hour burn-in period**
   - Intensive monitoring (24/7 on-call)
   - No changes to firewall rules (stability window)
5. **Decommission legacy path**
   - Remove routes to legacy firewall
   - Disable VPN/peering to legacy VPCs
   - Archive legacy firewall config
6. **Clean up unused resources**
   - Delete legacy address groups, NAT rules
   - Remove firewall appliance VMs (after 30-day grace period)

**Rollback Plan:**

If critical issues arise:

1. **DNS rollback** (update records to point back to legacy LB)
2. **Re-enable legacy routes** (VPC peering, VPN tunnels)
3. **Investigate root cause** (AI agent analyzes logs, suggests fixes)
4. **Fix and retry cutover** (after validation in shadow environment)

**Rollback Triggers:**
- Packet loss >1%
- Latency increase >20%
- Security policy violation detected
- Critical service outage >5 minutes

**Recovery Time Objective (RTO):** <2 hours

**AI Agent Tasks:**

```markdown
Agent Task: "Monitor cutover and alert on anomalies"
Input: Real-time metrics from cloud environment (LB, VPC, NAT logs)
Output:
  - Live dashboard (refreshed every 60 seconds)
  - Alerts on:
    - Error rate spike (>1% 5xx errors)
    - Latency spike (p95 >threshold)
    - Traffic drop (requests/second <baseline)
    - Firewall deny spike (unexpected blocks)
  - Automated rollback recommendation if thresholds exceeded
  - Post-cutover report (success metrics, issues encountered, lessons learned)
```

**Expected Duration:** 5-7 days (including burn-in period)

---

## AI Agent Prompts & Tasks

See the [prompts/](../prompts/) folder for detailed prompt templates for each phase.

Quick reference:

| Phase | Prompt File | Description |
|-------|-------------|-------------|
| Phase 1 | `01-foundation-vpc.md` | Generate Terraform for management, hub, egress, shared VPCs |
| Phase 2 | `02-spoke-vpc-mapping.md` | Map firewall NAT rules to cloud load balancers |
| Phase 2 | `03-firewall-rule-generation.md` | Generate VPC firewall rules from legacy config |
| Phase 3 | `04-database-isolation.md` | Create database VPC with no internet route |
| Phase 3 | `05-hierarchical-policies.md` | Deploy organization-level firewall policies |
| Phase 4 | `06-test-suite-generation.md` | Generate automated connectivity and security tests |
| Phase 5 | `07-log-analysis.md` | Compare legacy vs cloud logs, detect anomalies |
| Phase 6 | `08-cutover-monitoring.md` | Monitor cutover, alert on issues |

---

## Validation & Testing

### Test Suite Structure

```
tests/
├── connectivity/
│   ├── external-lb-tests.sh         # Curl each external LB
│   ├── east-west-tests.sh           # Spoke → Hub → Spoke
│   ├── bastion-ssh-tests.sh         # IAP tunnel to workloads
│   └── database-connectivity.sh     # App → DB cluster
├── egress/
│   ├── saas-connectivity-tests.sh   # SendGrid, payment gateways, etc.
│   ├── google-apis-tests.sh         # Private Google Access
│   └── deny-rules-tests.sh          # Attempt blocked endpoints
├── security/
│   ├── database-isolation-test.sh   # Verify no internet from DB
│   ├── cross-spoke-block-test.sh    # Verify no direct spoke-to-spoke
│   ├── iap-auth-test.sh             # Verify IAP requires correct IAM role
│   └── firewall-logging-test.sh     # Verify deny logs appear
├── performance/
│   ├── latency-comparison.sh        # Compare legacy vs cloud
│   └── throughput-tests.sh          # Load testing with ab/wrk
└── compliance/
    ├── policy-analyzer-check.sh     # Automated policy validation
    └── audit-report.sh              # Generate compliance report
```

### Automated Testing with AI Agent

AI agent can generate test scripts based on your specific configuration:

```markdown
Agent Task: "Generate comprehensive test suite"

Input:
  - Network topology (VPC peering diagram)
  - Security requirements (firewall rules, deny lists)
  - Service catalog (all external LBs, backends, SaaS dependencies)
  - Performance baselines (legacy latency, throughput)

Output:
  - Bash scripts for connectivity tests (external LB, east-west, SSH)
  - Bash scripts for egress tests (SaaS, APIs, deny rules)
  - Bash scripts for security tests (negative tests, isolation checks)
  - Performance test scripts (latency, throughput, comparison)
  - CI/CD integration (GitHub Actions / Cloud Build YAML)
  - Test report template (Markdown with pass/fail results, timestamps)
  - Automated rollback trigger (if >X% tests fail, alert)
```

---

## Rollback Procedures

### Rollback Decision Matrix

| Issue Severity | Action | Timeline |
|----------------|--------|----------|
| **Critical** (service down, packet loss >1%) | Immediate DNS rollback | <30 min |
| **High** (latency >20%, intermittent failures) | Rollback within 1 hour, investigate | <1 hour |
| **Medium** (minor errors, non-critical service impact) | Monitor, fix in shadow environment | <24 hours |
| **Low** (cosmetic issues, non-user-facing) | Fix in next maintenance window | <1 week |

### Step-by-Step Rollback

1. **Declare rollback decision** (incident commander + stakeholders)
2. **DNS rollback:**
   ```bash
   # Update DNS to point back to legacy LB IP
   gcloud dns record-sets transaction start --zone=example-zone
   gcloud dns record-sets transaction remove --zone=example-zone \
     --name=app.example.com. --type=A --ttl=60 "NEW_LB_IP"
   gcloud dns record-sets transaction add --zone=example-zone \
     --name=app.example.com. --type=A --ttl=60 "LEGACY_LB_IP"
   gcloud dns record-sets transaction execute --zone=example-zone
   ```
3. **Verify traffic shift:**
   ```bash
   # Monitor DNS resolution
   watch -n 5 "dig @8.8.8.8 app.example.com +short"

   # Monitor legacy LB receiving traffic again
   gcloud monitoring timeseries list \
     --filter='metric.type="loadbalancing.googleapis.com/https/request_count"'
   ```
4. **Re-enable legacy routes** (if VPC peering was removed):
   ```bash
   gcloud compute networks peerings create legacy-peering \
     --network=vpc-app \
     --peer-network=legacy-vpc \
     --auto-create-routes
   ```
5. **Incident report:**
   - AI agent generates timeline of events
   - Root cause analysis (which component failed, why)
   - Corrective actions (how to fix before retry)
6. **Fix and retry:**
   - Address root cause in shadow environment
   - Re-run Phase 4-5 validation
   - Schedule new cutover window

---

## Post-Migration Optimization

### Week 11-12: Stabilization

**Focus:** Monitor intensively, tune firewall rules based on production traffic

**Tasks:**
- [ ] 24/7 on-call rotation (network + security engineers)
- [ ] Daily review of deny logs (identify false positives)
- [ ] Tune Cloud Armor rules (adjust rate limits, geo-blocking)
- [ ] Optimize NAT gateway (monitor port utilization, add IPs if needed)
- [ ] Update documentation (actual vs planned, lessons learned)

**AI Agent Support:**
```markdown
Agent Task: "Analyze production traffic and recommend optimizations"
Input: 7 days of VPC Flow Logs, Firewall Logs, Cloud NAT logs
Output:
  - Over-permissive firewall rules (allow 0.0.0.0/0 that could be narrowed)
  - Under-utilized resources (e.g., reserved IPs not being used)
  - High-traffic services (candidates for autoscaling, caching)
  - Anomalous traffic patterns (new destinations, unexpected protocols)
  - Cost optimization recommendations (e.g., committed use discounts)
```

### Month 3: Optimization

**Cost Optimization:**
- [ ] Right-size load balancer forwarding rules (remove unused)
- [ ] Review Cloud NAT IP allocation (release extra IPs)
- [ ] Enable Cloud CDN for static content (reduce origin load)
- [ ] Committed Use Discounts for predictable workloads

**Security Enhancements:**
- [ ] Enable VPC Service Controls (perimeter around sensitive data)
- [ ] Implement Certificate Authority Service for workload mTLS
- [ ] Integrate with SIEM (Chronicle, Splunk) for advanced correlation
- [ ] Schedule quarterly firewall rule audits (Policy Analyzer)

**Performance Tuning:**
- [ ] Enable HTTP/3 on external LBs (lower latency for mobile clients)
- [ ] Optimize health check intervals (reduce unnecessary traffic)
- [ ] Review connection draining settings (graceful shutdowns)

### Month 4+: Decommission Legacy

**Final Steps:**
1. **Archive legacy firewall config** (export to version control)
2. **Delete legacy appliance VMs** (cancel licenses)
3. **Remove legacy VPC peering** (clean up network topology)
4. **Update runbooks** (remove references to legacy architecture)
5. **Team training** (ensure ops team comfortable with cloud-native tools)

**Knowledge Transfer:**
- [ ] Runbook: Add new external LB (step-by-step)
- [ ] Runbook: Modify firewall rule (VPC vs hierarchical policy)
- [ ] Runbook: Troubleshoot connectivity failure (flow logs, policy analyzer)
- [ ] Runbook: Rollback procedure (DNS, routes, incident process)

---

## Conclusion

This toolkit provides a comprehensive, AI-accelerated approach to migrating from legacy appliance-based firewalls to cloud-native security. By following the phased methodology and leveraging AI agents for automation, you can:

- **Reduce migration time** from months to weeks
- **Minimize human error** through automated validation
- **Improve security posture** with architecture-enforced controls
- **Lower costs** by 30-50% (eliminating appliance licenses)
- **Increase reliability** with cloud-native SLAs (99.99%+)

### Next Steps

1. **Assess your current environment** (export firewall config, inventory networks)
2. **Set up AI agent access** (API keys, example templates)
3. **Create shadow project** (isolated testing environment)
4. **Execute Phase 1** (foundation VPCs, management access)
5. **Iterate through phases** (validate before proceeding)
6. **Cutover with confidence** (parallel run, automated testing)

### Support & Contributions

This is an open-source toolkit. Contributions welcome:

- **GitHub Issues:** Report bugs, request features
- **Pull Requests:** Share your AI prompts, test scripts, Terraform modules
- **Discussions:** Share lessons learned, ask questions

**License:** MIT (free to use, modify, distribute)

**Maintainers:** Cloud migration community

---

**Document Version:** 1.0
**Last Updated:** 2025
**Feedback:** [github.com/yourorg/ai-agent-migration-toolkit/issues](https://github.com)
