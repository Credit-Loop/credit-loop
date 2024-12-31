```mermaid
graph TB
    %% External Actors
    User((User))
    Admin((Admin))

    subgraph Diamond["Diamond Contract (Proxy)"]
        direction TB
        
        subgraph CoreFacets["Core Facets"]
            direction LR
            DF[DebtFacet]
            CF[ChainFacet]
            PF[PaymentFacet]
            AF[AccessControlFacet]
            TF[TaxFacet]
        end
        
        subgraph VerificationFacets["Verification Facets"]
            direction LR
            IV[IdentityVerifierFacet]
            DV[DocumentVerifierFacet]
        end
        
        subgraph OracleFacets["Oracle Facets"]
            direction LR
            TO[TaxOracleFacet]
            CO[ChainOptimizerFacet]
        end
    end
    
    subgraph ExternalSystems["External Systems"]
        direction LR
        TS[Tax Service]
        OS[Optimization Service]
        IS[Identity Service]
        DS[Document Verification Service]
        AI[AI Document Analysis]
        ZK[ZK Proof Service]
    end
    
    subgraph Storage["Diamond Storage"]
        direction LR
        DS[(DebtStorage)]
        CS[(ChainStorage)]
        AS[(AccessStorage)]
        TSt[(TaxStorage)]
        VS[(VerificationStorage)]
    end

    %% User flows through Diamond
    User --> Diamond
    Diamond --> DF
    Diamond --> CF
    Diamond --> PF
    
    %% Admin flows through Diamond
    Admin --> Diamond
    Diamond --> AF
    Diamond --> TF
    
    %% Core Facet Storage Interactions
    DF <-->|"Store/Read Debt Data"| DS
    CF <-->|"Store/Read Chain Data"| CS
    PF <-->|"Store/Read Payment Data"| DS
    PF <-->|"Read Tax Data"| TSt
    AF <-->|"Store/Read Access Rights"| AS
    TF <-->|"Store/Read Tax Data"| TSt
    
    %% Verification Flows
    IV <-->|"Verify Identity"| IS
    DV <-->|"Verify Documents"| DS
    DV <-->|"AI Analysis"| AI
    DV <-->|"ZK Proofs"| ZK
    
    %% Oracle-External System Interactions
    TO <-->|"Get Tax Rates/Submit Reports"| TS
    CO <-->|"Get Optimal Routes"| OS
    
    %% Cross-Facet Dependencies
    DF -->|"Check Identity"| IV
    DF -->|"Verify Debt Docs"| DV
    CF -->|"Verify Access"| AF
    PF -->|"Verify Access"| AF
    PF -->|"Calculate Tax"| TF
    
    %% Storage Interactions for Verification
    IV <-->|"Cache Identity Status"| VS
    DV <-->|"Cache Doc Verification"| VS
    
    classDef coreStyle fill:#6495ED,stroke:#333,stroke-width:2px
    classDef verificationStyle fill:#FF69B4,stroke:#333,stroke-width:2px
    classDef oracleStyle fill:#DDA0DD,stroke:#333,stroke-width:2px
    classDef externalStyle fill:#98FB98,stroke:#333,stroke-width:2px
    classDef storageStyle fill:#FFA07A,stroke:#333,stroke-width:2px
    classDef proxyStyle fill:#E6E6FA,stroke:#333,stroke-width:4px
    classDef actorStyle fill:#FFD700,stroke:#333,stroke-width:2px
    
    class DF,CF,PF,AF,TF coreStyle
    class IV,DV verificationStyle
    class TO,CO oracleStyle
    class TS,OS,IS,DS,AI,ZK externalStyle
    class DS,CS,AS,TSt,VS storageStyle
    class Diamond proxyStyle
    class User,Admin actorStyle

# System Flow Description

## Verification System

### Types of Verification

1. **Identity Verification (One-time per wallet)**
   - Purpose: Verify user's real-world identity
   - When: User first joins the system
   - Components:
     - IdentityVerifierFacet: Manages identity verification status
     - External Identity Service: Performs actual KYC
     - AccessStorage: Stores verification status
   - Process:
     1. User completes traditional KYC through external service
     2. Identity service verifies documents and information
     3. IdentityVerifierFacet caches verification status
     4. Status enables basic system access

2. **Debt Document Verification (Per debt creation)**
   - Purpose: Verify authenticity and terms of debt agreements
   - When: Creating new debts or modifying existing ones
   - Components:
     - DocumentVerifierFacet: Manages document verification
     - AI Document Analysis: Extracts debt terms
     - ZK Proof Service: Ensures privacy
     - Document Verification Service: Validates authenticity
   - Process:
     1. User uploads debt documents
     2. AI service extracts key terms
     3. Document service verifies authenticity
     4. ZK proofs generated for private information
     5. On-chain data matched with document terms
   - Document Lifecycle:
     1. Initial verification
     2. Possible revocation (with reason)
     3. Possible replacement with new document
     4. Expiry tracking
     5. Status history maintenance

### Verification Flows

1. **System Access Flow**
   ```mermaid
   sequenceDiagram
       User->>IdentityVerifierFacet: Request Access
       IdentityVerifierFacet->>Identity Service: Verify Identity
       Identity Service-->>IdentityVerifierFacet: Verification Result
       IdentityVerifierFacet->>AccessStorage: Cache Status
       IdentityVerifierFacet-->>User: Access Granted/Denied
   ```

2. **Debt Document Verification Flow**
   ```mermaid
   sequenceDiagram
       User->>DocumentVerifierFacet: Submit Document
       DocumentVerifierFacet->>AI Analysis: Extract Terms
       AI Analysis-->>DocumentVerifierFacet: Terms Extracted
       DocumentVerifierFacet->>ZK Service: Generate Privacy Proofs
       ZK Service-->>DocumentVerifierFacet: ZK Proofs
       DocumentVerifierFacet->>Document Service: Verify Authenticity
       Document Service-->>DocumentVerifierFacet: Verification Result
       DocumentVerifierFacet-->>User: Document Status Updated

       alt Document Invalid
           DocumentVerifierFacet->>User: Verification Failed (with reason)
       else Document Needs Update
           User->>DocumentVerifierFacet: Submit New Version
           DocumentVerifierFacet->>DocumentVerifierFacet: Link Old & New Versions
       else Document Revoked
           User->>DocumentVerifierFacet: Revoke Document
           DocumentVerifierFacet->>DocumentVerifierFacet: Update Status & History
       end
   ```

3. **Debt Creation with Verification Flow**
   ```mermaid
   sequenceDiagram
       User->>DebtFacet: Create Debt
       DebtFacet->>IdentityVerifierFacet: Check Identity
       IdentityVerifierFacet-->>DebtFacet: Identity Valid
       DebtFacet->>DocumentVerifierFacet: Verify Debt Document
       DocumentVerifierFacet->>AI Analysis: Extract Terms
       DocumentVerifierFacet->>Document Service: Verify Authenticity
       DocumentVerifierFacet-->>DebtFacet: Document Valid
       DebtFacet->>DebtFacet: Create Debt with Verified Terms
       DebtFacet-->>User: Debt Created
   ```

### Integration Points

1. **DebtFacet Integration**
   - Requires valid identity verification
   - Requires valid debt document verification
   - Matches extracted terms with submitted data
   - Uses ZK proofs for private information
   - Handles document lifecycle events

2. **ChainFacet Integration**
   - Verifies identity of all chain participants
   - Validates all related debt documents
   - Ensures documents haven't been revoked/replaced
   - Maintains chain integrity with document updates

3. **PaymentFacet Integration**
   - Uses identity verification for transactions
   - Validates payment terms against verified documents
   - Handles document updates affecting payments
   - Maintains payment history with document references

### Document Lifecycle Management

1. **Document States**
   - Pending Verification
   - Verified
   - Failed Verification
   - Revoked
   - Replaced
   - Expired

2. **State Transitions**
   - Initial Submission → Verification
   - Verification → Success/Failure
   - Verified → Revoked
   - Verified → Replaced
   - Any State → Expired

3. **History Tracking**
   - Maintains complete document history
   - Tracks all state changes
   - Links replaced documents
   - Records verification attempts
   - Stores revocation reasons

4. **Privacy Considerations**
   - ZK proofs for sensitive information
   - Minimal on-chain data storage
   - Secure term extraction
   - Private document linking
   - Protected verification status