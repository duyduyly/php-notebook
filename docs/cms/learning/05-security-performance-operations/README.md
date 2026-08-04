# Stage 05 — Security, Performance, and Operations

A CMS is not production-ready until it can be secured, observed, backed up, recovered, and operated under failure.

## Table of Contents

1. [Objectives](#objectives)
2. [Security](#security)
3. [Performance](#performance)
4. [Caching](#caching)
5. [Deployment and Operations](#deployment-and-operations)
6. [Production Practice](#production-practice)
7. [Completion Checklist](#completion-checklist)

## Objectives

Learn to identify common vulnerabilities, diagnose bottlenecks, design cache boundaries, automate deployment, and prepare recovery procedures.

## Security

Study and test defenses for:

- SQL injection;
- cross-site scripting;
- cross-site request forgery;
- broken access control;
- insecure direct object references;
- unsafe file uploads;
- path traversal;
- session fixation and session theft;
- remote code execution;
- vulnerable dependencies;
- leaked credentials and secrets;
- unsafe extension installation.

### Security Principles

- Validate input at trust boundaries.
- Escape output for its destination context.
- Use parameterized database queries.
- Enforce authorization on the server.
- Restrict upload type, size, name, and storage location.
- Keep secrets outside source control.
- Patch core and dependencies deliberately.
- Record security-sensitive operations in audit logs.
- Apply least privilege to users, services, files, and databases.

## Performance

Investigate:

- slow database queries;
- missing or ineffective indexes;
- N+1 query patterns;
- expensive plugin execution;
- oversized media;
- excessive template rendering;
- synchronous external calls;
- large sessions;
- inefficient search;
- memory and CPU constraints.

Use measurements before optimization. Record the baseline, hypothesis, change, and result.

## Caching

```text
Browser cache
→ CDN cache
→ Reverse-proxy cache
→ Full-page cache
→ Fragment cache
→ Application or object cache
→ Query cache
→ Database buffer cache
```

For every cache, define:

1. cached object;
2. cache key;
3. owner and visibility;
4. expiration policy;
5. invalidation trigger;
6. behavior when cache is unavailable;
7. protection against serving private content to the wrong user.

## Deployment and Operations

Learn:

- Linux fundamentals;
- Apache or Nginx;
- application runtime management;
- environment variables;
- containers and Docker Compose;
- database and file backups;
- scheduled jobs and queue workers;
- log collection and rotation;
- metrics, traces, and alerts;
- health checks;
- release, rollback, and maintenance procedures;
- disaster recovery objectives.

### Suggested Runtime Structure

```text
Docker Compose
├── Reverse proxy or web server
├── CMS application
├── Relational database
├── Redis or equivalent cache
├── Queue worker
├── Scheduled-task runner
└── Monitoring components
```

## Production Practice

Deploy a CMS environment containing:

- separated configuration and secrets;
- persistent database and media storage;
- health checks;
- backup and restore scripts;
- structured logs;
- cache configuration;
- HTTPS termination;
- update and rollback checklist;
- recovery test results.

## Completion Checklist

- [ ] I can perform a basic CMS security review.
- [ ] I can prove that server-side permissions are enforced.
- [ ] I can profile and explain a performance bottleneck.
- [ ] I can design safe cache keys and invalidation rules.
- [ ] I can deploy the CMS in a reproducible environment.
- [ ] I can restore the system from backups.
- [ ] I have tested at least one failure and recovery procedure.
