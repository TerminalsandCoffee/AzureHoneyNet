# SOC 1 Role Interview Prep Guide

**Interview Details:**
- **Role:** SOC 1 (Security Operations Center Level 1)

---

## Quick Project Pitch (30 seconds)

*"I built an Azure honeynet project that demonstrates practical SOC experience. I deployed intentionally exposed Azure resources, captured real-world attack traffic, and used Microsoft Sentinel to detect and analyze threats. The project shows measurable results - implementing security controls reduced security incidents from 348 to zero over a 24-hour period. I developed custom KQL queries for threat detection, created automated alert rules mapped to MITRE ATT&CK, and demonstrated the full security operations lifecycle from log collection to incident response."*

---

## Key Talking Points

### 1. **Project Overview** (2 minutes)
- Built a honeynet in Azure to capture real-world attack traffic
- Integrated multiple log sources (Windows Event Logs, Linux Syslog, Azure AD, Key Vault, Storage Accounts)
- Used Microsoft Sentinel (SIEM/SOAR) for threat detection and incident management
- Measured security metrics before and after implementing controls

### 2. **Technical Skills Demonstrated** (3 minutes)
- **SIEM Operations:** Microsoft Sentinel configuration and management
- **Log Analysis:** KQL query development for threat detection
- **Security Control Implementation:** NSG rules, Private Endpoints, firewall configuration
- **Incident Response:** Alert creation, incident triage, security event correlation
- **Cloud Security:** Azure infrastructure security best practices

### 3. **Measurable Impact** (2 minutes)
- **100% reduction** in security incidents (348 → 0)
- **99% reduction** in Linux authentication failures (3,028 → 25)
- **55% reduction** in Windows security events (19,470 → 8,778)
- **Zero malicious network flows** allowed after hardening

### 4. **SOC-Relevant Experience** (3 minutes)
- **Threat Detection:** Custom KQL queries for brute force attacks, malware detection, privilege escalation
- **Alert Tuning:** Developed alert rules with appropriate thresholds and MITRE ATT&CK mapping
- **Log Correlation:** Correlated events across multiple sources (Windows, Linux, Azure services)
- **Security Posture Assessment:** Measured and documented security control effectiveness

---

## Common SOC 1 Interview Questions & Answers

### **Q: What interests you about SOC work?**
**Answer:** *"I'm fascinated by the detective work involved in security operations - analyzing logs, correlating events, and identifying patterns that indicate threats. My honeynet project gave me hands-on experience with this, and I found the process of developing KQL queries to detect attacks like brute force attempts really engaging. I'm motivated by the mission-critical nature of SOC work - being the first line of defense and helping protect organizations from threats."*

### **Q: Describe a time you analyzed a security event.**
**Answer:** *"In my honeynet project, I developed KQL queries to detect brute force attacks. For example, I created a query that correlates failed authentication attempts with successful logons from the same IP address. When testing this, I was able to identify patterns like multiple failed SSH attempts followed by a successful login, which would indicate a potential credential compromise. I then created automated alert rules in Microsoft Sentinel to detect these patterns and generate incidents automatically."*

### **Q: How would you prioritize security alerts?**
**Answer:** *"I'd prioritize based on severity and potential impact. In my project, I configured alerts with different severity levels - High for successful brute force attacks or privilege escalation attempts, Medium for brute force attempts, and so on. I'd also consider factors like: whether it's a successful attack vs. an attempt, the criticality of the affected system, and whether it matches known attack patterns. Real-time detection of active threats would take precedence over historical analysis."*

### **Q: What is your experience with SIEM tools?**
**Answer:** *"I have hands-on experience with Microsoft Sentinel. In my honeynet project, I configured log ingestion from multiple sources, developed custom KQL queries for threat detection, created automated alert rules with incident correlation, and analyzed security events. I understand the fundamentals of log normalization, event correlation, and alert tuning. I'm also familiar with creating custom dashboards and workbooks for security monitoring."*

### **Q: Explain the difference between an alert and an incident.**
**Answer:** *"An alert is a single detection event - like a failed login attempt or malware detection. An incident is a collection of related alerts that are correlated together, often representing a broader attack campaign. In my project, I configured Microsoft Sentinel to automatically group related alerts into incidents. For example, multiple failed authentication attempts from the same IP followed by a successful login would generate several alerts, but they'd be grouped into a single incident representing a brute force attack."*

### **Q: How do you handle false positives?**
**Answer:** *"False positives are a common challenge in SOC work. In my project, I learned that alert tuning is critical - setting appropriate thresholds and fine-tuning queries to reduce noise. For example, my brute force detection rules required at least 10 failed attempts within an hour to trigger, rather than alerting on every single failed login. When I do encounter false positives, I'd document them, adjust thresholds or queries as needed, and ensure the alert remains effective at catching real threats while reducing noise."*

### **Q: What is MITRE ATT&CK and how have you used it?**
**Answer:** *"MITRE ATT&CK is a framework that categorizes adversary tactics and techniques. In my project, I mapped my custom alert rules to MITRE ATT&CK techniques. For example, my brute force detection rules are mapped to T1110 (Brute Force), privilege escalation alerts to T1078 (Valid Accounts), and malware detection to Execution techniques. This helps with threat intelligence and understanding the attacker's methodology."*

### **Q: How would you handle a security incident?**
**Answer:** *"I'd follow a structured incident response process:*
1. *Initial Triage - Assess the alert/incident severity and potential impact*
2. *Investigation - Gather additional context using SIEM queries, check related events*
3. *Containment - If necessary, isolate affected systems (though as SOC 1, I'd escalate)*
4. *Documentation - Document findings, timeline, and indicators of compromise*
5. *Escalation - Escalate to SOC 2/3 or incident response team if needed*
6. *Follow-up - Ensure alerts are properly tuned based on findings*

*In my project, I gained experience with the investigation phase through KQL query development and log analysis."*

### **Q: What security logs are most important for SOC monitoring?**
**Answer:** *"From my project experience, the most critical logs are:*
- *Authentication logs (Windows Event Logs, Linux Syslog) - detect credential attacks*
- *Network logs (NSG flow logs) - identify malicious traffic patterns*
- *Application logs (Azure AD Sign-in logs) - detect account compromise*
- *Security service logs (Key Vault, Storage Account) - detect unauthorized access*
- *Endpoint detection logs (Windows Defender) - detect malware*

*In my honeynet, I ingested all of these sources into Log Analytics and created queries to correlate events across them."*

### **Q: How do you stay current with cybersecurity threats?**
**Answer:** *"I follow several sources:*
- *Microsoft Security blogs and advisories (especially relevant for Azure)*
- *MITRE ATT&CK updates and threat intelligence reports*
- *Security research from organizations like CISA*
- *Hands-on practice through projects like this honeynet*
- *I'm also interested in pursuing relevant certifications like Security+ or Azure Security Engineer"*

---

## Technical Deep-Dive Points

### **If Asked About KQL Queries:**
- Explain how you developed queries using `summarize`, `join`, and correlation techniques
- Mention your brute force detection queries that correlate failed and successful logons
- Discuss using regex patterns to extract IP addresses from log messages
- Highlight your understanding of time-based analysis (`ago()`, `TimeGenerated`)

### **If Asked About Microsoft Sentinel:**
- Describe configuring log ingestion from multiple data sources
- Explain creating custom analytics rules with appropriate thresholds
- Discuss incident correlation and grouping configuration
- Mention entity mapping (IP addresses, hostnames, user accounts)

### **If Asked About Network Security:**
- Explain NSG rule configuration and network segmentation
- Discuss Private Endpoints for securing Azure services
- Describe the zero-trust principles applied
- Highlight the difference between network-level and application-level controls

### **If Asked About Threat Detection:**
- Explain how you detect brute force attacks (correlating failed/successful attempts)
- Describe malware detection using Windows Defender logs
- Discuss privilege escalation detection (Global Admin assignments, Key Vault access)
- Mention lateral movement indicators (excessive password resets)

---

## Connecting Project to SOC 1 Responsibilities

### **SOC 1 Core Responsibilities → Your Project Experience**

| SOC 1 Responsibility | Your Project Experience |
|---------------------|------------------------|
| **Monitor security alerts** | Configured and tested automated alert rules in Microsoft Sentinel |
| **Triage security incidents** | Created incident correlation rules and analyzed grouped alerts |
| **Analyze log data** | Developed KQL queries to analyze Windows, Linux, and Azure logs |
| **Document security events** | Documented attack patterns, metrics, and security control effectiveness |
| **Escalate to SOC 2/3** | Understand severity levels and when escalation is appropriate (project demonstrated High/Medium severity classifications) |
| **Use SIEM tools** | Hands-on experience with Microsoft Sentinel configuration and querying |
| **Understand attack patterns** | Identified brute force attacks, privilege escalation, malware detection patterns |
| **Security metrics reporting** | Measured and compared security metrics before/after controls |

---

## Project-Specific Talking Points

### **What Makes This Project Stand Out:**
1. **Real-World Attack Traffic** - Captured actual malicious traffic from the internet
2. **Measurable Results** - Quantifiable security improvements (348 incidents → 0)
3. **End-to-End SOC Workflow** - Log collection → Detection → Alerting → Incident response
4. **Production-Ready Artifacts** - Exportable alert rules, reusable KQL queries
5. **Multi-Platform Coverage** - Windows, Linux, Azure services (comprehensive)

### **Challenges You Overcame:**
- **Log Correlation Complexity** - Learned to correlate events across multiple log sources
- **Alert Tuning** - Balanced between catching real threats and minimizing false positives
- **KQL Query Development** - Developed complex queries using joins, summaries, and regex
- **Security Control Design** - Implemented defense-in-depth with NSGs, firewalls, and Private Endpoints

### **What You Learned:**
- Importance of proper log ingestion and normalization
- Value of security metrics and measurement
- How security controls directly impact threat detection
- Critical thinking in threat detection and incident response

---

## Quick Reference: 30-Second Project Summary

**If you only have 30 seconds:**
*"I built an Azure honeynet that demonstrates full SOC workflow - log collection, threat detection, and incident response using Microsoft Sentinel. I developed custom KQL queries, created automated alert rules, and measured security improvements showing a 100% reduction in incidents after implementing controls. The project includes production-ready artifacts like exportable Sentinel rules and reusable query templates."*

---


