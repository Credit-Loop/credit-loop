# DebtChain System Flow

## System Components

### Core Components
1. Diamond Contract (Main Proxy)
2. Core Facets (Debt, Chain, Payment, Access Control)
3. Oracle Facets (Tax, Chain Optimizer)
4. Verification Facets (Identity, Document)
5. Storage Libraries

### External Services
1. Identity Verification Service
2. Document Verification Service
3. AI Analysis Service
4. ZK Proof Service
5. Tax Service
6. Chain Optimization Service

## Detailed Flow Diagram

```mermaid
sequenceDiagram
    participant Users as Users (A/B/C)
    participant Diamond as Diamond Contract
    participant CoreF as Core Facets
    participant VerifF as Verification Facets
    participant OracleF as Oracle Facets
    participant ExtServ as External Services
    
    Note over Users,ExtServ: Phase 1: Identity Verification
    Users->>Diamond: Connect wallet
    Diamond->>VerifF: Request identity verification
    VerifF->>ExtServ: Verify identity (KYC)
    ExtServ-->>VerifF: Identity verified
    VerifF-->>Diamond: Cache verification status
    Diamond-->>Users: Access granted

    Note over Users,ExtServ: Phase 2: Debt Creation & Document Verification
    Users->>Diamond: Submit debt documents
    Diamond->>VerifF: Request document verification
    VerifF->>ExtServ: Extract terms (AI Analysis)
    ExtServ-->>VerifF: Terms extracted
    VerifF->>ExtServ: Generate ZK proof
    ExtServ-->>VerifF: ZK proof generated
    VerifF-->>Diamond: Document verified
    Diamond->>CoreF: Create debt with verified terms

    Note over Users,ExtServ: Phase 3: Chain Detection & Optimization
    CoreF->>CoreF: Auto-detect potential chain
    Diamond->>OracleF: Request chain optimization
    OracleF->>ExtServ: Optimize chain path
    ExtServ-->>OracleF: Return optimal path
    OracleF-->>Diamond: Update chain configuration

    Note over Users,ExtServ: Phase 4: Chain Resolution & Consent
    Users->>Diamond: Request chain resolution
    Diamond->>CoreF: Validate chain participants
    CoreF->>VerifF: Check identity statuses
    VerifF-->>CoreF: Identities confirmed
    Users->>Diamond: Provide consent
    Diamond->>CoreF: Record consent

    Note over Users,ExtServ: Phase 5: Payment Processing & Tax
    Users->>Diamond: Initiate payment
    Diamond->>OracleF: Calculate tax obligations
    OracleF->>ExtServ: Get tax rates
    ExtServ-->>OracleF: Return tax calculations
    Diamond->>CoreF: Process payment
    CoreF->>ExtServ: Route tax payment
    CoreF->>Users: Route remaining funds

    Note over Users,ExtServ: Phase 6: Status Updates
    Diamond->>CoreF: Update debt statuses
    CoreF->>VerifF: Update document states
    Diamond->>OracleF: Update tax records
    Diamond-->>Users: Notify completion

    Note over Users,ExtServ: All interactions through Diamond Proxy
```

## Key Points

1. **User Interaction**
   - All user interactions go through the Diamond proxy
   - Diamond delegates to appropriate facets

2. **Facet Organization**
   - Core Facets: Basic debt and chain operations
   - Verification Facets: Identity and document verification
   - Oracle Facets: External service integration

3. **External Services**
   - Identity verification (KYC)
   - Document analysis (AI)
   - Privacy (ZK Proofs)
   - Tax calculations
   - Chain optimization

4. **Security Flow**
   - Identity verification required first
   - Document verification before debt creation
   - Consent required for chain resolution
   - Privacy preserved through ZK proofs

5. **Payment Flow**
   - Tax calculation before routing
   - Automatic payment splitting
   - Status updates across all components 