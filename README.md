# AI Agent Migration Toolkit

## Automate Cloud Network Migrations from Legacy Firewalls to Cloud-Native Architecture

This toolkit enables organizations to migrate from appliance-based network security (Palo Alto, Fortinet, Checkpoint) to cloud-native solutions (GCP, AWS, Azure) using AI agents to accelerate and de-risk the process.

---

## What This Toolkit Provides

- **Complete migration methodology** from planning to execution
- **AI agent prompts and guidelines** for automating infrastructure generation
- **Terraform templates** for hub-and-spoke VPC architecture
- **Automated test suites** for validation and compliance
- **Documentation templates** for runbooks, diagrams, and reports

---

## Key Benefits

| Benefit | Traditional Approach | With AI Agent Toolkit |
|---------|---------------------|----------------------|
| **Migration Time** | 4-6 months | 8-12 weeks |
| **Human Error Risk** | High (manual rule mapping) | Low (automated validation) |
| **Cost Savings** | 20-30% | 30-50% (includes automation time savings) |
| **Documentation** | Often incomplete | Auto-generated and up-to-date |
| **Rollback Capability** | Manual, risky | Automated, tested |

---

## Quick Start

### Prerequisites

- [ ] Cloud provider account (GCP, AWS, or Azure)
- [ ] Firewall configuration export (XML, JSON, or API access)
- [ ] AI agent access (Claude, GPT-4, Gemini, or equivalent)
- [ ] Terraform installed (`brew install terraform` or equivalent)
- [ ] Basic networking knowledge (VPCs, subnets, firewalls)

### Installation

```bash
# Clone this repository
git clone https://github.com/yourorg/ai-agent-migration-toolkit.git
cd ai-agent-migration-toolkit

# Set up environment
export CLOUD_PROJECT="your-shadow-project"  # Isolated test environment
export AI_AGENT_API_KEY="your-api-key"

# Verify prerequisites
./scripts/check-prerequisites.sh
```

### Step 1: Export Your Firewall Configuration

```bash
# Example for Palo Alto Panorama
# (Adapt for your firewall vendor)
ssh admin@panorama.example.com
> set cli config-output-format xml
> show running-config > firewall-export.xml

# Or use API
curl -k -X GET "https://panorama.example.com/api/?type=export&category=configuration" \
  -H "X-PAN-KEY: $API_KEY" > firewall-export.xml
```

### Step 2: Run AI Agent Analysis

```bash
# Use the AI agent to parse your firewall config
cat prompts/phase1-analyze-firewall.md | \
  ai-agent-cli --input firewall-export.xml > analysis-report.md

# Review the analysis
cat analysis-report.md
```

**Example Output:**
```markdown
## Firewall Analysis Report

**Total Rules:** 1,247
**NAT Rules:** 37
**Security Rules:** 1,210

### Key Findings:
- 17 external services requiring load balancers
- 12 VPC networks to migrate
- 4 critical services (database tier requires isolation)
- Estimated migration time: 8-10 weeks
```

### Step 3: Generate Infrastructure-as-Code

```bash
# Use AI agent to generate Terraform modules
cat prompts/phase2-generate-terraform.md | \
  ai-agent-cli \
    --input analysis-report.md \
    --output terraform/

# Output:
# terraform/
# ├── vpc-management.tf
# ├── vpc-hub.tf
# ├── vpc-egress.tf
# ├── vpc-app.tf
# └── firewall-rules.tf
```

### Step 4: Deploy to Shadow Environment

```bash
cd terraform/

# Initialize Terraform
terraform init

# Preview changes (dry-run)
terraform plan

# Deploy (requires approval)
terraform apply
```

### Step 5: Validate Migration

```bash
# Run automated test suite
./tests/run-all-tests.sh

# Example output:
# ✅ Connectivity Tests: 45/45 passed
# ✅ Security Tests: 23/23 passed
# ✅ Performance Tests: 8/8 passed
# ⚠️  Warnings: 2 (non-critical)
```

---

## Architecture Overview

### Target Design: Hub-and-Spoke VPC Architecture

```
┌─────────────────────────────────────────────────────┐
│ Management VPC (IAP Access, No Internet)            │
│ → Bastion hosts, VPN gateway                        │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Hub VPC (East-West Traffic Only)                    │
│ → Internal load balancers for inter-VPC routing     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Egress Proxy VPC (Centralized Internet Egress)      │
│ → Cloud NAT with single egress IP                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Shared Services VPC (Private Endpoints)             │
│ → Artifact repos, security tools (no internet)      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Spoke VPCs (Workload Isolation)                     │
│ → App VPC, Web VPC, Database VPC (no internet)      │
└─────────────────────────────────────────────────────┘
```

### Key Design Principles

1. **Architecture-Enforced Security:** Database VPC has NO peering to egress VPC (impossible to reach internet)
2. **Centralized Egress:** Single NAT IP for all workloads (simplifies SaaS allow-listing)
3. **Defense in Depth:** Cloud Armor → External LB → VPC Firewall → Hierarchical Policies
4. **Zero-Trust Access:** IAP + OS Login for admin access (no VPN required)

---

## Repository Structure

```
ai-agent-migration-toolkit/
├── README.md                          # This file
├── docs/
│   ├── 00-master-guide.md             # Complete migration methodology
│   ├── 01-ai-agent-guidelines.md      # How to operate AI agents
│   ├── 02-architecture-patterns.md    # Cloud network design patterns
│   └── 03-security-best-practices.md  # Security hardening guide
├── prompts/
│   ├── phase1-analyze-firewall.md     # Parse firewall config
│   ├── phase2-generate-terraform.md   # Generate IaC
│   ├── phase3-validate-security.md    # Security compliance checks
│   └── phase4-test-generation.md      # Create test scripts
├── templates/
│   ├── terraform/
│   │   ├── vpc-module/                # Reusable VPC module
│   │   ├── firewall-module/           # Firewall rules module
│   │   └── load-balancer-module/      # LB configuration module
│   └── tests/
│       ├── connectivity/               # Connectivity test scripts
│       ├── security/                   # Security validation scripts
│       └── performance/                # Performance benchmarking
├── examples/
│   ├── gcp-migration/                  # Complete GCP example
│   ├── aws-migration/                  # AWS example (Security Groups)
│   └── azure-migration/                # Azure example (NSGs)
└── scripts/
    ├── check-prerequisites.sh          # Verify environment setup
    ├── export-firewall-config.sh       # Helper for firewall exports
    └── run-migration-phase.sh          # Execute migration phases
```

---

## Documentation

### Core Guides

1. **[Master Guide](docs/00-master-guide.md):** Complete migration methodology (planning to execution)
2. **[AI Agent Guidelines](docs/01-ai-agent-guidelines.md):** How to operate AI agents safely
3. **[Architecture Patterns](docs/02-architecture-patterns.md):** Cloud network design best practices
4. **[Security Best Practices](docs/03-security-best-practices.md):** Hardening your cloud network

### Phase-by-Phase Guides

| Phase | Duration | Description | Guide |
|-------|----------|-------------|-------|
| Phase 1 | Week 1-2 | Foundation VPCs (management, hub, egress) | [Phase 1 Guide](docs/phase1-foundation.md) |
| Phase 2 | Week 3-4 | Core spoke VPCs (app, web) | [Phase 2 Guide](docs/phase2-core-spokes.md) |
| Phase 3 | Week 5-6 | Database VPC, isolation | [Phase 3 Guide](docs/phase3-database.md) |
| Phase 4 | Week 7-8 | Validation & testing | [Phase 4 Guide](docs/phase4-validation.md) |
| Phase 5 | Week 9-10 | Parallel run | [Phase 5 Guide](docs/phase5-parallel-run.md) |
| Phase 6 | Week 11-12 | Cutover & stabilization | [Phase 6 Guide](docs/phase6-cutover.md) |

---

## AI Agent Prompts

All prompts are located in `prompts/` and follow this structure:

```markdown
# Prompt: [Task Name]

## Context
[Background information for the agent]

## Input
[What data/files the agent will receive]

## Task
[Specific instructions for what to generate]

## Output Format
[Expected structure of the output]

## Validation
[How to verify the output is correct]

## Example
[Sample input → output]
```

### Available Prompts

| Prompt | Purpose | Input | Output |
|--------|---------|-------|--------|
| `phase1-analyze-firewall.md` | Parse firewall config | XML/JSON export | Structured analysis (JSON) |
| `phase2-generate-terraform.md` | Generate IaC | Network requirements | Terraform modules |
| `phase3-validate-security.md` | Security checks | Terraform plan | Compliance report |
| `phase4-test-generation.md` | Create test scripts | Topology, requirements | Bash/Python tests |
| `phase5-log-analysis.md` | Compare logs | Legacy + cloud logs | Anomaly report |
| `phase6-cutover-monitoring.md` | Monitor cutover | Real-time metrics | Alert dashboard |

---

## Terraform Templates

### Module Structure

```
templates/terraform/
├── vpc-module/
│   ├── main.tf              # VPC, subnets
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # VPC ID, subnet IDs
│   └── README.md            # Usage documentation
├── firewall-module/
│   ├── main.tf              # VPC firewall rules
│   ├── hierarchical.tf      # Org-level policies
│   └── variables.tf
└── load-balancer-module/
    ├── external-lb.tf       # External HTTPS LB
    ├── internal-lb.tf       # Internal passthrough LB
    └── variables.tf
```

### Usage Example

```hcl
# environments/production/main.tf

module "vpc_management" {
  source = "../../templates/terraform/vpc-module"

  vpc_name = "vpc-management"
  cidr     = "10.0.5.0/24"
  region   = "us-central1"

  subnets = {
    bastion = {
      cidr                    = "10.0.5.0/27"
      private_google_access   = true
    }
    vpn = {
      cidr                    = "10.0.5.32/27"
      private_google_access   = false
    }
  }

  firewall_rules = {
    allow_iap = {
      direction     = "INGRESS"
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["bastion"]
      allowed = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  }
}
```

---

## Testing

### Test Suite Categories

1. **Connectivity Tests** (`tests/connectivity/`)
   - External LB reachability
   - East-west traffic (spoke → hub → spoke)
   - Bastion SSH via IAP

2. **Security Tests** (`tests/security/`)
   - Database isolation (verify no internet route)
   - Cross-spoke blocking (direct spoke-to-spoke fails)
   - IAP authentication (requires correct IAM role)

3. **Performance Tests** (`tests/performance/`)
   - Latency comparison (legacy vs cloud)
   - Throughput benchmarking
   - NAT port utilization

4. **Compliance Tests** (`tests/compliance/`)
   - Policy Analyzer checks
   - Firewall rule auditing
   - VPC Service Controls validation

### Running Tests

```bash
# Run all tests
./tests/run-all-tests.sh

# Run specific category
./tests/connectivity/external-lb-tests.sh

# Run with verbose output
./tests/run-all-tests.sh --verbose

# Generate test report
./tests/run-all-tests.sh --report > test-report.md
```

---

## Examples

### Complete Migration Examples

#### GCP Example
```bash
cd examples/gcp-migration/
cat README.md  # Step-by-step guide

# Uses:
# - Palo Alto Panorama export
# - 12 VPC networks → 8 VPCs (hub-and-spoke)
# - 17 external HTTPS load balancers
# - Hierarchical firewall policies
```

#### AWS Example
```bash
cd examples/aws-migration/
cat README.md  # AWS-specific guide

# Uses:
# - AWS Security Groups export
# - VPC Transit Gateway (hub)
# - Network Firewall for egress inspection
# - PrivateLink for shared services
```

#### Azure Example
```bash
cd examples/azure-migration/
cat README.md  # Azure-specific guide

# Uses:
# - Azure NSG rules export
# - Hub-and-spoke with Azure Firewall
# - Private Endpoints for PaaS services
# - Azure Bastion for admin access
```

---

## Roadmap

### Current Features (v1.0)
- [x] Complete migration methodology
- [x] AI agent prompts for all phases
- [x] GCP Terraform templates
- [x] Automated test suites
- [x] Documentation templates

### Planned Features (v1.1)
- [ ] AWS CloudFormation templates
- [ ] Azure ARM/Bicep templates
- [ ] Multi-cloud migration (hybrid)
- [ ] Kubernetes network policy generation
- [ ] Cost estimation and optimization
- [ ] Compliance framework mapping (PCI DSS, SOC 2, ISO 27001)

### Future Enhancements (v2.0)
- [ ] AI agent auto-execution (fully autonomous)
- [ ] Real-time migration monitoring dashboard
- [ ] Automatic rollback on anomaly detection
- [ ] Integration with SIEM (Splunk, Chronicle)
- [ ] Machine learning for traffic pattern analysis

---

## Contributing

We welcome contributions! Here's how you can help:

### Areas for Contribution

1. **New Cloud Providers:** AWS, Azure, Alibaba Cloud templates
2. **Firewall Vendors:** FortiGate, Checkpoint, Cisco ASA parsers
3. **AI Agent Prompts:** Improved prompts for specific use cases
4. **Test Scripts:** Additional validation and security tests
5. **Documentation:** Translations, tutorials, troubleshooting guides

### Contribution Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-aws-template`)
3. Make your changes
4. Test thoroughly (run existing test suite)
5. Submit a pull request with clear description

### Code Style

- **Terraform:** Follow HashiCorp style guide (use `terraform fmt`)
- **Bash:** Follow Google Shell Style Guide
- **Markdown:** Use tables for structured data, code blocks for examples
- **AI Prompts:** Include context, task, output format, validation, example

---

## Support & Community

### Getting Help

- **GitHub Issues:** [Report bugs or request features](https://github.com/yourorg/ai-agent-migration-toolkit/issues)
- **Discussions:** [Ask questions, share learnings](https://github.com/yourorg/ai-agent-migration-toolkit/discussions)
- **Wiki:** [Community-contributed guides and FAQs](https://github.com/yourorg/ai-agent-migration-toolkit/wiki)

### Enterprise Support

For organizations requiring:
- Custom migration planning
- On-site consulting
- Priority support
- Training workshops

Contact: support@ai-migration-toolkit.com

---

## License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

You are free to:
- Use commercially
- Modify
- Distribute
- Sublicense

With attribution and no warranty.

---

## Acknowledgments

This toolkit is built on lessons learned from:
- Cloud migration best practices (GCP, AWS, Azure)
- Open-source IaC frameworks (Terraform, Pulumi)
- AI agent research (LangChain, AutoGPT, Claude)
- Network security standards (NIST, CIS Benchmarks)

Special thanks to the cloud migration community for sharing their experiences.

---

## Quick Links

- [Master Migration Guide](docs/00-master-guide.md)
- [AI Agent Guidelines](docs/01-ai-agent-guidelines.md)
- [Terraform Templates](templates/terraform/)
- [Test Suites](templates/tests/)
- [GCP Example](examples/gcp-migration/)

---

**Version:** 1.0
**Last Updated:** 2025
**Maintained by:** Cloud Migration Community
**Contributions:** Welcome via pull requests
**License:** MIT
