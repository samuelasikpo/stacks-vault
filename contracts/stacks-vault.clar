;; StacksVault - Decentralized Lending Protocol
;;
;; StacksVault is a next-generation DeFi lending protocol built on Stacks Layer 2
;; that enables users to deposit STX as collateral and borrow against it with
;; competitive interest rates and automated liquidation mechanisms.
;;
;; Key Features:
;; - Overcollateralized lending with 150% minimum collateral ratio
;; - Automated interest accrual and liquidation protection
;; - Protocol fee collection for sustainable operations
;; - Emergency pause functionality for security
;; - Transparent loan health monitoring
;;
;; Security: The protocol implements robust checks for collateral ratios,
;; interest calculations, and liquidation thresholds to ensure system stability.

;; CONSTANTS & ERROR DEFINITIONS

(define-constant CONTRACT-OWNER tx-sender)

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INSUFFICIENT-BALANCE (err u402))
(define-constant ERR-INVALID-AMOUNT (err u403))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u404))
(define-constant ERR-LOAN-NOT-FOUND (err u405))
(define-constant ERR-LOAN-ALREADY-EXISTS (err u406))
(define-constant ERR-MATH-OVERFLOW (err u407))
(define-constant ERR-LOAN-NOT-LIQUIDATABLE (err u408))
(define-constant ERR-LOAN-NOT-REPAYABLE (err u409))
(define-constant ERR-INVALID-LOAN-ID (err u410))

;; Protocol Configuration Constants
(define-constant COLLATERAL-RATIO u150) ;; 150% minimum collateral ratio
(define-constant LIQUIDATION-THRESHOLD u130) ;; 130% liquidation threshold
(define-constant INTEREST-RATE-YEARLY u50) ;; 5.0% annual interest (scaled by 10)
(define-constant BLOCKS-PER-YEAR u52560) ;; ~10 minute blocks, 365 days
(define-constant PROTOCOL-FEE-PERCENT u10) ;; 1.0% protocol fee from interest

;; Calculated Constants
(define-constant INTEREST-RATE-PER-BLOCK (/ (* INTEREST-RATE-YEARLY u100000) (* BLOCKS-PER-YEAR u1000)))

;; DATA STRUCTURES

;; User deposit tracking
(define-map user-deposits
  principal
  uint
)

;; Historical deposit tracking
(define-map total-deposits
  uint
  uint
) ;; [height, amount]

;; Protocol fee accumulation
(define-map protocol-fees
  uint
  uint
) ;; [height, amount]

;; Loan data structure
(define-map loans
  { loan-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    loan-amount: uint,
    interest-accumulated: uint,
    creation-height: uint,
    last-interest-height: uint,
    status: (string-ascii 20),
  }
)

;; User loan tracking
(define-map user-loans
  principal
  (list 20 uint)
)

;; STATE VARIABLES

(define-data-var loan-nonce uint u0)
(define-data-var total-collateral uint u0)
(define-data-var total-borrowed uint u0)
(define-data-var paused bool false)

;; ADMINISTRATIVE FUNCTIONS

;; Pause or unpause the protocol (emergency function)
(define-public (set-paused (paused-state bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set paused paused-state)
    (ok paused-state)
  )
)