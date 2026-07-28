# HikaShop 6.5.2 Installation & Feature Guide (Joomla 6)

> **Version:** 6.5.2  
> **Compatibility:** Joomla 4 / 5 / 6  
> **Recommended for Migration:** ✅ Yes  
> **Official Website:** <https://www.hikashop.com>  
> **Download:** <https://www.hikashop.com/download.html>

---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Core Features](#2-core-features)
- [3. Download HikaShop](#3-download-hikashop)
- [4. Install via Joomla Installer](#4-install-via-joomla-installer)
- [5. Install via Discover](#5-install-via-discover)
- [6. Upgrade Free to Business or Essential](#6-upgrade-free-to-business-or-essential)
- [7. Verify Installation](#7-verify-installation)
- [8. Feature Testing Guide](#8-feature-testing-guide)
- [9. Migration Checklist](#9-migration-checklist)
- [10. Recommended Installation Method](#10-recommended-installation-method)
- [11. Summary](#11-summary)

---

## 1. Overview

HikaShop is a complete eCommerce extension for Joomla. It provides product catalog, cart, checkout, payment, shipping, order, customer, email, tax, inventory, and reporting features.

```mermaid
flowchart TD
    A[Customer] --> B[Product Catalog]
    B --> C[Shopping Cart]
    C --> D[Checkout]
    D --> E[Payment]
    D --> F[Shipping]
    E --> G[Order]
    F --> G
    G --> H[Invoice]
    G --> I[Emails]
```

---

## 2. Core Features

| Feature | Purpose |
|---|---|
| Product Management | Create and manage physical, digital, and configurable products. |
| Categories | Organize products into catalog structures. |
| Shopping Cart | Add, remove, and update cart items. |
| Checkout | Collect billing, shipping, payment, and confirmation information. |
| Orders | Create, review, update, and track orders. |
| Customers | Manage customer profiles and order history. |
| Coupons | Apply discounts based on configured rules. |
| Taxes | Calculate tax based on configured zones and rules. |
| Shipping | Configure shipping methods, prices, and restrictions. |
| Payment Gateways | Integrate supported online and offline payment methods. |
| Inventory | Track stock and product availability. |
| Product Variants | Support attributes such as size, color, and other options. |
| Digital Downloads | Deliver downloadable products after purchase. |
| Multi-language | Support multilingual product and store content. |
| Multi-currency | Display and process supported currencies. |
| Reports | Review sales, orders, customers, and product data. |

---

## 3. Download HikaShop

### 3.1 Free Edition

Download from:

- Official website: <https://www.hikashop.com/download.html>
- Joomla Extension Directory: <https://extensions.joomla.org/extension/e-commerce/shopping-cart/hikashop/>

### 3.2 Business or Essential Edition

Log in to the licensed HikaShop account:

```text
My Account
→ Downloads
→ Business or Essential Package
```

---

## 4. Install via Joomla Installer

### 4.1 Installation Flow

```mermaid
flowchart TD
    A[Download HikaShop ZIP] --> B[Log in to Joomla Administrator]
    B --> C[System]
    C --> D[Install]
    D --> E[Extensions]
    E --> F[Upload Package File]
    F --> G[Select ZIP File]
    G --> H[Upload and Install]
    H --> I[Installation Successful]
```

### 4.2 Steps

1. Log in to Joomla Administrator:

```text
https://your-domain/administrator
```

2. Navigate to:

```text
System → Install → Extensions
```

3. Select **Upload Package File**.
4. Choose the HikaShop installation package, for example:

```text
com_hikashop_v6.5.2.zip
```

5. Click **Upload & Install**.
6. Wait for Joomla to report:

```text
Installation of the package was successful.
```

7. Clear Joomla cache if required.

---

## 5. Install via Discover

> Use this method only when the HikaShop source files have already been copied manually into the Joomla installation.

### 5.1 Discover Flow

```mermaid
flowchart TD
    A[Copy HikaShop Files to Server] --> B[Joomla Administrator]
    B --> C[System]
    C --> D[Discover]
    D --> E[Discover Extensions]
    E --> F[Select HikaShop]
    F --> G[Install]
```

### 5.2 Steps

1. Copy the extension files into the correct Joomla directories.
2. Open:

```text
System → Install → Discover
```

3. Click **Discover**.
4. Select HikaShop when it appears.
5. Click **Install**.
6. Verify that all required components, modules, and plugins are registered.

---

## 6. Upgrade Free to Business or Essential

HikaShop can normally be upgraded without uninstalling the Starter edition. Existing store data and configuration should remain intact.

### 6.1 Upgrade Flow

```mermaid
flowchart LR
    A[Starter Edition] --> B[Configure Store]
    B --> C[Purchase License]
    C --> D[Download Business or Essential ZIP]
    D --> E[Install ZIP over Existing Edition]
    E --> F[Paid Features Enabled]
```

### 6.2 Upgrade Steps

1. Install and configure **HikaShop Starter**.
2. Purchase a Business or Essential license.
3. Download the licensed package.
4. Open:

```text
System → Install → Extensions
```

5. Upload the Business or Essential ZIP package.
6. Do not uninstall the Starter edition first.
7. Clear Joomla and browser cache if the new features do not appear immediately.

### 6.3 Expected Result

The following data should remain intact:

- Products.
- Categories.
- Product images.
- Customers.
- Orders.
- Coupons.
- Taxes.
- Shipping configuration.
- Payment configuration.
- Email templates.
- Store configuration.
- Database records.

Only the additional paid-edition features should be enabled.

---

## 7. Verify Installation

### 7.1 Verification Flow

```mermaid
flowchart TD
    A[Open Administrator] --> B[Components]
    B --> C[HikaShop Dashboard]
    C --> D[Verify Version]
    D --> E[Create Product]
    E --> F[Create Category]
    F --> G[Test Cart]
    G --> H[Test Checkout]
    H --> I[Test Email]
    I --> J[Installation Verified]
```

### 7.2 Installation Checklist

#### Administrator

- [ ] **Components → HikaShop** exists.
- [ ] HikaShop dashboard opens successfully.
- [ ] No HTTP 500 error occurs.
- [ ] No PHP exception occurs.

#### Version

Open the HikaShop version or About screen and verify:

```text
Version: 6.5.2
```

#### Core Data Screens

- [ ] Products page loads.
- [ ] Categories page loads.
- [ ] Customers page loads.
- [ ] Orders page loads.
- [ ] Configuration page loads and saves successfully.

#### PHP and Browser Checks

- [ ] No fatal PHP error.
- [ ] No deprecated warning affecting functionality.
- [ ] No blank or white page.
- [ ] No related error appears in Joomla logs.
- [ ] No blocking JavaScript error appears in the browser console.

---

## 8. Feature Testing Guide

Run these tests on a Joomla 6 staging environment before production deployment.

### 8.1 Product Management

- [ ] Create a simple product.
- [ ] Edit the product name, price, description, stock, and image.
- [ ] Publish and unpublish the product.
- [ ] Verify the product on the frontend.
- [ ] Delete a test product and confirm that the expected cleanup behavior occurs.

### 8.2 Categories

- [ ] Create a product category.
- [ ] Create a child category.
- [ ] Assign products to the category.
- [ ] Verify category listing pages on the frontend.
- [ ] Verify menu items linked to HikaShop categories.

### 8.3 Product Variants and Inventory

- [ ] Create a product with variants such as size or color.
- [ ] Verify variant price and stock values.
- [ ] Confirm out-of-stock behavior.
- [ ] Confirm stock is reduced after a successful order when configured.

### 8.4 Shopping Cart

- [ ] Add a product to the cart.
- [ ] Add a product variant to the cart.
- [ ] Update quantity.
- [ ] Remove an item.
- [ ] Verify subtotal and total calculations.
- [ ] Verify cart persistence according to project requirements.

### 8.5 Checkout

- [ ] Enter billing information.
- [ ] Enter shipping information.
- [ ] Select a shipping method.
- [ ] Select a payment method.
- [ ] Apply tax correctly.
- [ ] Apply a coupon correctly.
- [ ] Submit the order.
- [ ] Display the order confirmation page.

### 8.6 Orders

- [ ] Verify order creation.
- [ ] Verify product, tax, shipping, discount, and total values.
- [ ] Change the order status.
- [ ] Verify order history.
- [ ] Verify invoice generation when used.

### 8.7 Customers

- [ ] Create a customer during checkout.
- [ ] Create or edit a customer from the administrator area.
- [ ] Verify the customer address.
- [ ] Verify customer order history.
- [ ] Verify guest checkout when enabled.

### 8.8 Coupons

- [ ] Create a coupon.
- [ ] Apply the coupon to a valid cart.
- [ ] Verify minimum-order rules.
- [ ] Verify expiration rules.
- [ ] Verify usage limits.
- [ ] Confirm invalid coupons are rejected.

### 8.9 Taxes

- [ ] Verify tax rules for the configured location.
- [ ] Verify taxable and non-taxable products.
- [ ] Verify prices displayed with or without tax according to configuration.
- [ ] Verify tax values in the order and invoice.

### 8.10 Shipping

- [ ] Verify all required shipping methods are available.
- [ ] Verify shipping prices.
- [ ] Verify location, weight, price, and product restrictions when used.
- [ ] Confirm unavailable shipping methods are hidden correctly.

### 8.11 Payment

- [ ] Verify all required payment plugins are installed and enabled.
- [ ] Complete a test payment in sandbox or test mode.
- [ ] Verify successful payment status updates.
- [ ] Verify cancelled and failed payment behavior.
- [ ] Verify return and callback URLs.
- [ ] Verify webhook or server notification processing when used.

### 8.12 Emails

- [ ] Customer order confirmation is sent.
- [ ] Administrator notification is sent.
- [ ] Order-status email is sent when applicable.
- [ ] Email subject, content, totals, and links are correct.
- [ ] Migrated or customized email templates render correctly.

### 8.13 Digital Downloads

Run this section only when the project sells downloadable products.

- [ ] Digital product can be purchased.
- [ ] Download link is generated after the correct order status.
- [ ] Unauthorized users cannot access the file.
- [ ] Download limits and expiration rules work when configured.

### 8.14 Multi-language and Multi-currency

- [ ] Product translations display correctly.
- [ ] Category translations display correctly.
- [ ] Checkout labels display in the selected language.
- [ ] Currency switching works.
- [ ] Product, cart, and order totals remain consistent.

### 8.15 Reports

- [ ] Sales reports load.
- [ ] Order reports match actual order data.
- [ ] Product reports load correctly.
- [ ] Date filters work.
- [ ] Exported data is correct when export is used.

### 8.16 Template Overrides and Custom Integrations

- [ ] HikaShop template overrides are compatible with Joomla 6.
- [ ] Custom CSS and JavaScript still work.
- [ ] Custom HikaShop plugins load correctly.
- [ ] Third-party payment plugins remain compatible.
- [ ] Third-party shipping plugins remain compatible.
- [ ] Custom fields display and save correctly.
- [ ] SEF URLs and menu routing behave correctly.
- [ ] Joomla cache does not produce stale cart or checkout data.

---

## 9. Migration Checklist

When migrating from **HikaShop 3.5.1** to **HikaShop 6.5.2**, verify the following.

### 9.1 Data Migration

- [ ] Products.
- [ ] Product variants.
- [ ] Categories.
- [ ] Product images.
- [ ] Customers.
- [ ] Customer addresses.
- [ ] Orders.
- [ ] Order history.
- [ ] Coupons.
- [ ] Taxes.
- [ ] Inventory and stock values.
- [ ] Digital download files and permissions.

### 9.2 Configuration Migration

- [ ] Store configuration.
- [ ] Cart configuration.
- [ ] Checkout workflow.
- [ ] Shipping methods.
- [ ] Payment plugins.
- [ ] Email templates.
- [ ] Custom fields.
- [ ] Multi-language configuration.
- [ ] Multi-currency configuration.
- [ ] Reports and exports.

### 9.3 Code and Compatibility

- [ ] Template overrides.
- [ ] Custom HikaShop plugins.
- [ ] Third-party HikaShop integrations.
- [ ] Joomla 6 compatibility.
- [ ] PHP 8.3 compatibility.
- [ ] PHP 8.4 compatibility when used by the target environment.
- [ ] No deprecated APIs affect critical functions.
- [ ] No database migration errors occur.
- [ ] No PHP fatal errors occur.

### 9.4 End-to-End Migration Flow

```mermaid
flowchart LR
    A[Install HikaShop 6.5.2] --> B[Migrate Data and Configuration]
    B --> C[Test Products and Categories]
    C --> D[Test Cart and Checkout]
    D --> E[Test Payment and Shipping]
    E --> F[Test Orders and Emails]
    F --> G[Production Readiness Review]
```

---

## 10. Recommended Installation Method

| Method | Recommendation |
|---|---|
| Joomla Extension Installer | ⭐⭐⭐⭐⭐ Recommended for normal installation and upgrade. |
| Discover | ⭐⭐ Use only when source files already exist in the Joomla installation. |
| Starter → Business or Essential | ⭐⭐⭐⭐⭐ Recommended; install the paid package over the existing edition. |

---

## 11. Summary

```text
Install HikaShop
        ↓
Verify Administrator and Version
        ↓
Configure Store
        ↓
Test Products and Categories
        ↓
Test Cart and Checkout
        ↓
Test Payment and Shipping
        ↓
Test Orders and Emails
        ↓
Complete Migration Checklist
        ↓
Ready for Production
```
