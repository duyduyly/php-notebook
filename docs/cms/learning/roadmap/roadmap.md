# CMS Learning Roadmap

A structured learning path from CMS beginner to CMS Solution Architect and, with sufficient real-world experience, CMS System Architect.

## Target

By completing this roadmap, you should be able to:

- understand how a CMS works from HTTP request to rendered content;
- configure and operate a production-ready CMS;
- design and build themes, plugins, modules, extensions, APIs, and workflows;
- customize architecture without unnecessarily modifying the CMS core;
- evaluate security, performance, scalability, maintainability, and operational risks;
- design traditional, headless, decoupled, multi-site, and enterprise CMS platforms;
- make system-design decisions based on functional and non-functional requirements.

**Expected role progression:** CMS Developer → Senior CMS Developer → CMS Technical Lead → CMS Solution Architect → CMS System Architect.

> Completing the material alone does not automatically make someone an architect. Professional-level capability requires knowledge, production projects, architectural decisions, and experience handling failures.

## Table of Contents

1. [Roadmap Structure](#roadmap-structure)
2. [Recommended Learning Order](#recommended-learning-order)
3. [Expected Outcomes](#expected-outcomes)
4. [Learning Method](#learning-method)
5. [Completion Criteria](#completion-criteria)

## Roadmap Structure

```text
docs/cms/learning/roadmap/
├── roadmap.md
├── stage-01-web-and-cms-foundations.md
├── stage-02-practical-cms-usage.md
├── stage-03-cms-architecture.md
├── stage-04-cms-development-and-customization.md
├── stage-05-security-performance-and-operations.md
├── stage-06-advanced-cms-architecture.md
├── stage-07-cms-system-design.md
├── stage-08-expert-practice-and-architecture-leadership.md
└── stage-09-projects-and-competency-assessment.md
```

| Stage | Main focus | Primary outcome |
|---|---|---|
| [01. Web and CMS Foundations](stage-01-web-and-cms-foundations.md) | Web, backend, database, and CMS fundamentals | Understand the problem a CMS solves |
| [02. Practical CMS Usage](stage-02-practical-cms-usage.md) | Content, users, media, menus, configuration | Operate a CMS confidently |
| [03. CMS Architecture](stage-03-cms-architecture.md) | Request lifecycle, services, data, rendering, extensions | Explain how a CMS works internally |
| [04. CMS Development and Customization](stage-04-cms-development-and-customization.md) | Themes, plugins, modules, custom extensions, APIs | Extend a CMS safely |
| [05. Security, Performance, and Operations](stage-05-security-performance-and-operations.md) | Security, cache, deployment, monitoring, recovery | Run a CMS reliably |
| [06. Advanced CMS Architecture](stage-06-advanced-cms-architecture.md) | Headless, decoupled, multi-site, workflow, search | Design advanced CMS solutions |
| [07. CMS System Design](stage-07-cms-system-design.md) | Requirements, scaling, consistency, failure design | Produce complete CMS system designs |
| [08. Expert Practice and Architecture Leadership](stage-08-expert-practice-and-architecture-leadership.md) | Architecture review, platform design, build-versus-buy | Make and defend architecture decisions |
| [09. Projects and Competency Assessment](stage-09-projects-and-competency-assessment.md) | Portfolio projects and competency checks | Prove practical capability |

## Recommended Learning Order

Follow the stages in order. Do not skip directly to distributed system design before understanding content modeling, permissions, rendering, extension boundaries, and production operations.

A realistic part-time schedule is **9–12 months** at approximately **8–12 hours per week**.

| Month | Focus |
|---|---|
| 1 | Web, backend, database, and authentication foundations |
| 2 | CMS concepts and practical CMS administration |
| 3 | Content models, users, permissions, media, and workflows |
| 4 | Request lifecycle and source-code navigation |
| 5 | Themes, templates, layouts, and rendering |
| 6 | Plugins, modules, events, and dependency injection |
| 7 | Custom applications, extensions, and REST APIs |
| 8 | Security, caching, and performance |
| 9 | Deployment, observability, backup, and recovery |
| 10 | Headless, multi-site, multilingual, and workflow design |
| 11 | Search, queues, asynchronous processing, and consistency |
| 12 | Enterprise CMS system design and architecture review |

## Expected Outcomes

After completing the roadmap and its projects, you should be able to:

1. install, configure, operate, debug, back up, and restore a CMS;
2. trace a request through routing, middleware, controllers, services, repositories, templates, and response generation;
3. design content types, relationships, revisions, permissions, workflows, and APIs;
4. build extensions without tightly coupling them to the CMS core;
5. identify security, performance, data-consistency, and operational risks;
6. design a scalable CMS using CDN, cache, object storage, search, queues, workers, monitoring, and resilient databases;
7. compare an existing CMS, a headless platform, a SaaS CMS, and a custom-built solution;
8. document and defend architectural trade-offs.

## Learning Method

Use this cycle for every major topic:

```text
Use the feature
→ Observe its behavior
→ Read the source code
→ Draw the request and data flow
→ Implement a small version
→ Break it intentionally
→ Debug the failure
→ Document the findings
→ Compare alternative designs
```

For each topic, record:

1. the problem being solved;
2. the participating components;
3. the request flow;
4. the data flow;
5. relevant source-code locations;
6. extension and customization points;
7. failure cases;
8. security risks;
9. performance considerations;
10. possible improvements and trade-offs.

## Completion Criteria

The roadmap is complete only when you can demonstrate all of the following:

- a self-built mini CMS;
- a real CMS project with custom extensions;
- a headless or decoupled CMS implementation;
- a deployed environment with backup, monitoring, and recovery procedures;
- at least one documented performance investigation;
- at least one documented security review;
- an enterprise CMS system-design document;
- clear explanations of major architectural decisions and rejected alternatives.
