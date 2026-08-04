[← Back to CMS Learning Roadmap](roadmap.md)

# Stage 08 — Expert Practice and Architecture Leadership

This stage focuses on evaluating systems, making architectural decisions, and designing sustainable CMS platforms.

## Table of Contents

1. [Objectives](#objectives)
2. [Codebase Analysis](#codebase-analysis)
3. [Architecture Review](#architecture-review)
4. [Custom Architecture](#custom-architecture)
5. [Extension Platform Design](#extension-platform-design)
6. [Build-versus-Buy Decisions](#build-versus-buy-decisions)
7. [Architecture Leadership](#architecture-leadership)
8. [Completion Checklist](#completion-checklist)

## Objectives

Develop the ability to review unfamiliar CMS systems, identify structural risks, define platform boundaries, compare solution options, and communicate trade-offs to both technical and non-technical stakeholders.

## Codebase Analysis

When entering an unfamiliar CMS codebase, identify:

- application entry points;
- bootstrap and configuration loading;
- routing and middleware;
- authentication and authorization boundaries;
- service registration and dependency graph;
- extension discovery and lifecycle;
- content and revision storage;
- rendering and asset pipelines;
- cache layers;
- APIs and integration points;
- scheduled tasks and queue workers;
- logs, metrics, and failure handling.

Produce diagrams before proposing major changes.

## Architecture Review

Look for risks such as:

- business logic inside controllers or templates;
- direct core modifications;
- uncontrolled global state;
- hidden dependencies;
- circular extension dependencies;
- inconsistent permission checks;
- unsafe cache scopes;
- unbounded event side effects;
- fragile database schemas;
- missing migrations;
- synchronous external integrations;
- inadequate audit logging;
- weak failure isolation;
- undocumented operational assumptions.

Classify findings by severity, evidence, impact, and recommended action.

## Custom Architecture

Common customization points include:

- application services;
- repositories and storage adapters;
- content-type providers;
- workflow engines;
- permission evaluators;
- event subscribers;
- API resources;
- search providers;
- media processors;
- cache adapters;
- integration gateways.

Custom architecture should preserve stable contracts and avoid coupling business requirements to undocumented CMS internals.

## Extension Platform Design

A sustainable extension platform needs:

- stable public APIs;
- semantic versioning;
- declared dependencies;
- event contracts;
- lifecycle hooks;
- installation and migration mechanisms;
- compatibility policies;
- permission boundaries;
- configuration conventions;
- failure isolation;
- observability;
- deprecation and removal processes.

Consider whether third-party code requires sandboxing, restricted capabilities, or separate processes.

## Build-versus-Buy Decisions

| Option | Advantages | Main risks |
|---|---|---|
| Existing traditional CMS | Fast delivery and established ecosystem | Platform constraints and extension quality variation |
| Headless CMS | Flexible frontend and channel reuse | Preview, integration, and operational complexity |
| SaaS CMS | Reduced infrastructure operations | Vendor lock-in, pricing, and customization limits |
| Custom CMS | Full control over domain and architecture | High development, security, and maintenance cost |
| Hybrid solution | Balance of reusable platform and custom services | More integration boundaries and governance needs |

Evaluate total cost of ownership, delivery time, team capability, upgrade strategy, compliance, integration needs, scale, and exit cost.

## Architecture Leadership

An architect should be able to:

- convert business goals into technical constraints;
- propose multiple viable options;
- document trade-offs and rejected alternatives;
- define standards without blocking delivery;
- create migration paths rather than only target-state diagrams;
- review security, data, performance, and operations together;
- guide teams through incidents and post-incident improvements;
- communicate uncertainty and assumptions clearly.

## Completion Checklist

- [ ] I can analyze an unfamiliar CMS codebase systematically.
- [ ] I can produce an evidence-based architecture review.
- [ ] I can define stable customization boundaries.
- [ ] I can design an extension platform and compatibility policy.
- [ ] I can compare traditional, headless, SaaS, custom, and hybrid options.
- [ ] I can defend a recommendation using requirements and trade-offs.
- [ ] I can provide a realistic migration and operational plan.

[← Back to CMS Learning Roadmap](roadmap.md)
