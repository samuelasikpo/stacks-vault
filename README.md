# StacksVault - Decentralized Lending Protocol

[![Stacks](https://img.shields.io/badge/Built%20on-Stacks-5546FF.svg)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Smart%20Contract-Clarity-brightgreen.svg)](https://clarity-lang.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Next-generation DeFi lending protocol enabling overcollateralized borrowing on Stacks Layer 2

## 🚀 Overview

StacksVault is a decentralized lending protocol that allows users to deposit STX as collateral and borrow against it with competitive interest rates. Built with security-first principles, the protocol features automated liquidation mechanisms, real-time interest accrual, and transparent loan health monitoring.

### Key Features

- **🔒 Overcollateralized Lending**: 150% minimum collateral ratio ensures system stability
- **⚡ Real-time Interest**: Block-by-block interest accrual with 5% annual rate
- **🛡️ Liquidation Protection**: Automated liquidation at 130% threshold with liquidator incentives
- **💰 Protocol Revenue**: Sustainable fee collection (1% on interest, 50% of liquidation bonus)
- **🔐 Emergency Controls**: Admin pause functionality for security incidents
- **📊 Transparent Monitoring**: Comprehensive loan health and protocol statistics

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   User Wallet   │◄──►│  StacksVault    │◄──►│   Liquidators   │
│                 │    │   Protocol      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│  STX Deposits   │    │  Interest       │    │  Collateral     │
│  & Withdrawals  │    │  Calculation    │    │  Liquidation    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Contract Architecture

### Core Components

#### 1. **Collateral Management**

- `deposit()` - Lock STX as collateral
- `withdraw()` - Unlock unused collateral
- Real-time collateral tracking and validation

#### 2. **Loan Operations**

- `borrow()` - Create overcollateralized loans
- `repay-loan()` - Partial or full loan repayment
- `liquidate()` - Liquidate undercollateralized positions

#### 3. **Interest & Fee System**

- Block-by-block interest accrual (5% APY)
- Protocol fee collection (1% of interest)
- Liquidation bonus distribution (5% of collateral)

#### 4. **Risk Management**

- 150% minimum collateral ratio
- 130% liquidation threshold
- Automated health monitoring

### Data Structures

```clarity
;; User deposit tracking
(define-map user-deposits principal uint)

;; Comprehensive loan data
(define-map loans 
  { loan-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    loan-amount: uint,
    interest-accumulated: uint,
    creation-height: uint,
    last-interest-height: uint,
    status: (string-ascii 20)
  }
)

;; User loan portfolio
(define-map user-loans principal (list 20 uint))
```

## 🔄 Data Flow

### Borrowing Flow

```
1. User deposits STX collateral
   ↓
2. System validates collateral sufficiency (≥150%)
   ↓
3. Loan created with locked collateral
   ↓
4. STX borrowed amount transferred to user
   ↓
5. Interest begins accruing per block
```

### Liquidation Flow

```
1. Loan health monitoring (collateral ratio < 130%)
   ↓
2. Liquidator identifies undercollateralized loan
   ↓
3. Liquidator pays full debt amount
   ↓
4. Liquidator receives collateral + 5% bonus
   ↓
5. Protocol collects 50% of liquidation bonus
```

### Interest Calculation

```
Interest = Principal × (5% / 52,560 blocks) × Blocks Elapsed
Protocol Fee = Interest × 1%
```

## 🛠️ Quick Start

### Prerequisites

- Stacks CLI
- Clarinet for local development
- STX testnet tokens

### Deployment

```bash
# Clone repository
git clone https://github.com/samuelasikpo/stacks-vault.git
cd stacksvault-protocol

# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

### Basic Usage

```clarity
;; Deposit collateral
(contract-call? .stacksvault deposit u1000000) ;; 1 STX

;; Borrow against collateral
(contract-call? .stacksvault borrow u1000000 u600000) ;; Borrow 0.6 STX with 1 STX collateral

;; Repay loan
(contract-call? .stacksvault repay-loan u1 u650000) ;; Repay loan ID 1

;; Check loan health
(contract-call? .stacksvault get-loan-health u1)
```

## 📊 Protocol Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| **Collateral Ratio** | 150% | Minimum collateral required |
| **Liquidation Threshold** | 130% | Health ratio for liquidation |
| **Interest Rate** | 5% APY | Annual borrowing cost |
| **Protocol Fee** | 1% | Fee on interest payments |
| **Liquidation Bonus** | 5% | Incentive for liquidators |
| **Max Loans per User** | 20 | Portfolio limit |

## 🔐Security Features

### Risk Mitigation

- **Overcollateralization**: 150% minimum ratio prevents undercollateralized loans
- **Liquidation Incentives**: 5% bonus ensures timely liquidations
- **Emergency Pause**: Admin can halt operations during security incidents
- **Interest Cap**: Prevents mathematical overflow in interest calculations

### Access Controls

- **Admin Functions**: Contract owner exclusive access
- **Loan Management**: Borrower-only repayment rights
- **Public Liquidations**: Open liquidation market for efficiency

## 📈 Protocol Economics

### Revenue Model

1. **Interest Income**: 1% protocol fee on all interest payments
2. **Liquidation Fees**: 50% of liquidation bonus (2.5% of collateral)
3. **Sustainable Growth**: Fee reinvestment for protocol development

### Liquidator Incentives

- 5% bonus on liquidated collateral
- Immediate settlement
- No minimum liquidation amount

## 🧪 Testing

```bash
# Run test suite
clarinet test

# Check contract coverage
clarinet check

# Simulate transactions
clarinet console
```

## 📚 API Reference

### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `get-loan-details` | `loan-id: uint` | Loan data | Retrieve loan information |
| `get-loan-health` | `loan-id: uint` | Health metrics | Check loan status |
| `get-user-loans` | `user: principal` | Loan IDs | User's loan portfolio |
| `get-protocol-stats` | None | Protocol metrics | System statistics |
| `is-liquidatable` | `loan-id: uint` | Boolean | Liquidation eligibility |

### Public Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `deposit` | `amount: uint` | Deposit STX collateral |
| `withdraw` | `amount: uint` | Withdraw available collateral |
| `borrow` | `collateral: uint, loan: uint` | Create new loan |
| `repay-loan` | `loan-id: uint, amount: uint` | Repay existing loan |
| `liquidate` | `loan-id: uint` | Liquidate unhealthy loan |

## 🤝 Contributing

We welcome contributions to StacksVault! Please read our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

### Development Setup

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
