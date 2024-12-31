# Diamond Pattern Implementation for Debt Chain System

## Core Components

### Folder Structure

```plaintext
contracts/
├── diamond/
│   ├── interfaces/
│   │   ├── IDiamondCut.sol
│   │   ├── IDiamondLoupe.sol
│   │   ├── core/
│   │   │   ├── IDebtFacet.sol
│   │   │   ├── IChainFacet.sol
│   │   │   ├── IPaymentFacet.sol
│   │   │   ├── IAccessControlFacet.sol
│   │   │   └── ITaxFacet.sol
│   │   ├── verification/
│   │   │   ├── IIdentityVerifierFacet.sol
│   │   │   └── IDocumentVerifierFacet.sol
│   │   └── oracle/
│   │       ├── ITaxOracleFacet.sol
│   │       └── IChainOptimizerFacet.sol
│   ├── libraries/
│   │   └── LibDiamond.sol
│   ├── storage/
│   │   ├── LibDebtStorage.sol
│   │   ├── LibChainStorage.sol
│   │   ├── LibAccessStorage.sol
│   │   ├── LibTaxStorage.sol
│   │   ├── LibVerificationStorage.sol
│   │   └── LibOracleStorage.sol
│   ├── facets/
│   │   ├── core/
│   │   │   ├── DebtFacet.sol
│   │   │   ├── ChainFacet.sol
│   │   │   ├── PaymentFacet.sol
│   │   │   ├── AccessControlFacet.sol
│   │   │   └── TaxFacet.sol
│   │   ├── verification/
│   │   │   ├── IdentityVerifierFacet.sol
│   │   │   └── DocumentVerifierFacet.sol
│   │   └── oracle/
│   │       ├── TaxOracleFacet.sol
│   │       └── ChainOptimizerFacet.sol
│   └── Diamond.sol
```

### Diamond Contract
- Main proxy contract implementing ERC-2535
- Handles function delegation
- Manages state storage
- Emits events for all function changes

### Core Facets

1. **DebtFacet**
   - Core debt management functionality
   - Integration with verification system
   - Debt creation with document verification
   - Debt status management

2. **ChainFacet**
   - Chain detection and validation
   - Participant verification checks
   - Chain resolution with verified documents
   - Consent management

3. **PaymentFacet**
   - Payment processing with verification
   - Tax calculations and routing
   - Payment history tracking
   - Terms validation against documents

4. **AccessControlFacet**
   - Role management
   - Basic access control
   - Permission management
   - System parameter controls

### Verification Facets

1. **IdentityVerifierFacet**
   - One-time wallet identity verification
   - Integration with external KYC service
   - Identity status caching
   - Access control management

2. **DocumentVerifierFacet**
   - Debt document verification
   - AI-powered term extraction
   - ZK proof generation for privacy
   - Document authenticity validation

### Oracle Facets

1. **TaxOracleFacet**
   - Tax rate management
   - Payment calculations
   - Tax authority integration
   - Rate validity tracking

2. **ChainOptimizerFacet**
   - Route optimization
   - Chain validation
   - Efficiency calculations
   - Path recommendations

## Storage Layout

### Diamond Storage Pattern
Each component has isolated storage through dedicated libraries:

1. **Core Storage**
   - `LibDebtStorage`: Debt and payment data
   - `LibChainStorage`: Chain and route data
   - `LibAccessStorage`: Access control and roles
   - `LibTaxStorage`: Tax rates and calculations

2. **Verification Storage**
   - `LibVerificationStorage`: Identity and document verification data
   - Stores verification status and proofs
   - Manages validity periods
   - Caches external service results

3. **Oracle Storage**
   - `LibOracleStorage`: Oracle data and request tracking
   - Caches external service responses
   - Manages validity periods
   - Tracks request history

### Storage Positions
Each storage library uses unique positions:
```solidity
bytes32 constant STORAGE_POSITION = keccak256("debtchain.[type].storage");
```

## Implementation Strategy

1. **Phase 1: Core Infrastructure**
   - Deploy Diamond contract
   - Implement core facets
   - Setup basic storage structure
   - Basic event system

2. **Phase 2: Verification System**
   - Implement identity verification
   - Setup document verification
   - Integrate AI and ZK services
   - Privacy-preserving verification

3. **Phase 3: Oracle Integration**
   - Implement oracle facets
   - Setup external service connections
   - Chainlink integration
   - Error handling

4. **Phase 4: Security & Testing**
   - Role-based access control
   - Verification flow testing
   - Emergency pause functionality
   - Security audits

## External Integrations

1. **Identity Service**
   - Traditional KYC verification
   - Identity document validation
   - Compliance checks
   - Status management

2. **Document Verification Service**
   - Document authenticity checks
   - Term extraction via AI
   - Privacy-preserving verification
   - ZK proof generation

3. **Supporting Services**
   - AI for document analysis
   - ZK proof system
   - Tax calculation service
   - Chain optimization service

## Interface Definitions

### Identity Verification Interface
```solidity
interface IIdentityVerifierFacet {
    // Events
    event IdentityVerificationRequested(address indexed account, bytes32 requestId);
    event IdentityVerified(address indexed account, uint256 timestamp);
    event IdentityExpired(address indexed account, uint256 timestamp);
    event IdentityRevoked(address indexed account, string reason);

    // Structs
    struct IdentityStatus {
        bool isVerified;
        uint256 verificationTimestamp;
        uint256 expiryTimestamp;
        bytes32 lastRequestId;
    }

    // Core Functions
    function requestIdentityVerification() external returns (bytes32 requestId);
    function updateIdentityStatus(
        address account, 
        bool status, 
        uint256 expiryTimestamp
    ) external;
    function isIdentityValid(address account) external view returns (bool);
    function getIdentityStatus(address account) external view returns (IdentityStatus memory);
    function revokeIdentity(address account, string calldata reason) external;
}
```

### Document Verification Interface
```solidity
interface IDocumentVerifierFacet {
    // Events
    event DocumentVerificationRequested(
        bytes32 indexed requestId,
        address indexed submitter,
        bytes32 documentHash
    );
    event DocumentVerified(
        bytes32 indexed requestId,
        bytes32 documentHash,
        bool isValid
    );
    event TermsExtracted(
        bytes32 indexed requestId,
        bytes32 documentHash,
        bytes termsProof
    );
    event DocumentVerificationFailed(
        bytes32 indexed requestId,
        bytes32 documentHash,
        string reason
    );
    event DocumentRevoked(
        bytes32 indexed documentHash,
        address indexed revoker,
        string reason,
        uint256 timestamp
    );
    event DocumentReplaced(
        bytes32 indexed oldDocumentHash,
        bytes32 indexed newDocumentHash,
        address indexed submitter,
        uint256 timestamp
    );

    // Structs
    struct DocumentVerification {
        bytes32 documentHash;
        address submitter;
        uint256 timestamp;
        bool isVerified;
        bytes zkProof;
        bytes32 termsHash;
        uint256 expiryTimestamp;
    }

    struct VerificationRequest {
        bytes32 documentHash;
        address submitter;
        uint256 timestamp;
        bool isProcessed;
        bytes aiAnalysisResult;
        bytes zkProofRequest;
    }

    struct VerificationStatus {
        bool isVerified;
        bool isRevoked;
        bytes32 replacedBy;  // If document was replaced
        string failureReason;
        uint256 lastUpdateTimestamp;
    }

    // Core Functions
    function requestDocumentVerification(
        bytes32 documentHash,
        bytes calldata metadata
    ) external returns (bytes32 requestId);

    function submitVerificationResult(
        bytes32 requestId,
        bool isValid,
        bytes calldata zkProof,
        bytes32 termsHash
    ) external;

    function isDocumentValid(bytes32 documentHash) external view returns (bool);
    
    function getDocumentVerification(
        bytes32 documentHash
    ) external view returns (DocumentVerification memory);

    function revokeDocument(
        bytes32 documentHash,
        string calldata reason
    ) external;

    function replaceDocument(
        bytes32 oldDocumentHash,
        bytes32 newDocumentHash,
        bytes calldata metadata
    ) external returns (bytes32 requestId);

    function getVerificationStatus(
        bytes32 documentHash
    ) external view returns (VerificationStatus memory);
}
```

## Implementation Details

### Identity Verification Flow

1. **Initial Identity Verification**
```solidity
function requestIdentityVerification() external returns (bytes32) {
    require(!isIdentityValid(msg.sender), "Identity already verified");
    
    bytes32 requestId = keccak256(abi.encodePacked(
        msg.sender,
        block.timestamp,
        "IDENTITY_VERIFICATION"
    ));
    
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    vs.identityRequests[requestId] = IdentityRequest({
        account: msg.sender,
        timestamp: block.timestamp,
        isProcessed: false
    });
    
    emit IdentityVerificationRequested(msg.sender, requestId);
    return requestId;
}
```

2. **Status Update by Verifier**
```solidity
function updateIdentityStatus(
    address account,
    bool status,
    uint256 expiryTimestamp
) external {
    require(isAuthorizedVerifier(msg.sender), "Not authorized");
    require(expiryTimestamp > block.timestamp, "Invalid expiry");
    
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    vs.identityStatus[account] = IdentityStatus({
        isVerified: status,
        verificationTimestamp: block.timestamp,
        expiryTimestamp: expiryTimestamp,
        lastRequestId: vs.currentRequestId[account]
    });
    
    emit IdentityVerified(account, block.timestamp);
}
```

### Document Verification Flow

1. **Document Submission**
```solidity
function requestDocumentVerification(
    bytes32 documentHash,
    bytes calldata metadata
) external returns (bytes32) {
    require(isIdentityValid(msg.sender), "Identity not verified");
    
    bytes32 requestId = keccak256(abi.encodePacked(
        documentHash,
        msg.sender,
        block.timestamp
    ));
    
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    vs.documentRequests[requestId] = VerificationRequest({
        documentHash: documentHash,
        submitter: msg.sender,
        timestamp: block.timestamp,
        isProcessed: false,
        aiAnalysisResult: "",
        zkProofRequest: ""
    });
    
    emit DocumentVerificationRequested(requestId, msg.sender, documentHash);
    return requestId;
}
```

2. **AI Analysis Integration**
```solidity
function processAIAnalysis(
    bytes32 requestId,
    bytes calldata analysisResult
) external {
    require(isAuthorizedAIService(msg.sender), "Not authorized AI service");
    
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    VerificationRequest storage request = vs.documentRequests[requestId];
    require(!request.isProcessed, "Already processed");
    
    request.aiAnalysisResult = analysisResult;
    
    // Trigger ZK proof generation if all checks pass
    if (isValidAnalysis(analysisResult)) {
        generateZKProof(requestId, analysisResult);
    }
}
```

3. **ZK Proof Generation**
```solidity
function generateZKProof(
    bytes32 requestId,
    bytes memory analysisResult
) internal {
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    VerificationRequest storage request = vs.documentRequests[requestId];
    
    // Prepare ZK proof request
    request.zkProofRequest = abi.encode(
        request.documentHash,
        analysisResult,
        block.timestamp
    );
    
    // Emit event for off-chain ZK proof generation
    emit ZKProofRequested(requestId, request.zkProofRequest);
}
```

4. **Document Verification Result**
```solidity
function submitVerificationResult(
    bytes32 requestId,
    bool isValid,
    bytes calldata zkProof,
    bytes32 termsHash
) external {
    require(isAuthorizedVerifier(msg.sender), "Not authorized");
    
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    VerificationRequest storage request = vs.documentRequests[requestId];
    require(!request.isProcessed, "Already processed");
    
    // Verify ZK proof
    require(verifyZKProof(zkProof, request.documentHash), "Invalid ZK proof");
    
    // Store verification result
    vs.documentVerifications[request.documentHash] = DocumentVerification({
        documentHash: request.documentHash,
        submitter: request.submitter,
        timestamp: block.timestamp,
        isVerified: isValid,
        zkProof: zkProof,
        termsHash: termsHash,
        expiryTimestamp: block.timestamp + VERIFICATION_VALIDITY_PERIOD
    });
    
    request.isProcessed = true;
    emit DocumentVerified(requestId, request.documentHash, isValid);
}
```

5. **Document Revocation**
```solidity
function revokeDocument(
    bytes32 documentHash,
    string calldata reason
) external {
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    DocumentVerification storage doc = vs.documentVerifications[documentHash];
    
    require(
        msg.sender == doc.submitter || isAuthorizedVerifier(msg.sender),
        "Not authorized"
    );
    require(doc.isVerified, "Document not verified");
    require(!vs.verificationStatus[documentHash].isRevoked, "Already revoked");
    
    vs.verificationStatus[documentHash].isRevoked = true;
    vs.verificationStatus[documentHash].failureReason = reason;
    vs.verificationStatus[documentHash].lastUpdateTimestamp = block.timestamp;
    
    emit DocumentRevoked(
        documentHash,
        msg.sender,
        reason,
        block.timestamp
    );
}
```

6. **Document Replacement**
```solidity
function replaceDocument(
    bytes32 oldDocumentHash,
    bytes32 newDocumentHash,
    bytes calldata metadata
) external returns (bytes32 requestId) {
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    DocumentVerification storage oldDoc = vs.documentVerifications[oldDocumentHash];
    
    require(msg.sender == oldDoc.submitter, "Not document owner");
    require(oldDoc.isVerified, "Original document not verified");
    require(!vs.verificationStatus[oldDocumentHash].isRevoked, "Document already revoked");
    
    // Create new verification request
    requestId = requestDocumentVerification(newDocumentHash, metadata);
    
    // Update old document status
    vs.verificationStatus[oldDocumentHash].replacedBy = newDocumentHash;
    vs.verificationStatus[oldDocumentHash].lastUpdateTimestamp = block.timestamp;
    
    emit DocumentReplaced(
        oldDocumentHash,
        newDocumentHash,
        msg.sender,
        block.timestamp
    );
    
    return requestId;
}
```

7. **Status Checking**
```solidity
function getVerificationStatus(
    bytes32 documentHash
) external view returns (VerificationStatus memory) {
    return LibVerificationStorage.verificationStorage()
        .verificationStatus[documentHash];
}

function isDocumentValid(bytes32 documentHash) external view returns (bool) {
    VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
    DocumentVerification storage doc = vs.documentVerifications[documentHash];
    VerificationStatus storage status = vs.verificationStatus[documentHash];
    
    return doc.isVerified && 
           !status.isRevoked && 
           status.replacedBy == bytes32(0) &&
           block.timestamp <= doc.expiryTimestamp;
}
```

### Storage Management

```solidity
struct VerificationStorage {
    // Identity verification
    mapping(address => IdentityStatus) identityStatus;
    mapping(bytes32 => IdentityRequest) identityRequests;
    mapping(address => bytes32) currentRequestId;
    
    // Document verification
    mapping(bytes32 => DocumentVerification) documentVerifications;
    mapping(bytes32 => VerificationRequest) documentRequests;
    mapping(bytes32 => VerificationStatus) verificationStatus;
    mapping(address => bytes32[]) userDocuments;
    mapping(bytes32 => bytes32[]) documentHistory; // Tracks document replacements
    
    // Access control
    mapping(address => bool) authorizedVerifiers;
    mapping(address => bool) authorizedAIServices;
    
    // System parameters
    uint256 identityValidityPeriod;
    uint256 documentValidityPeriod;
    bytes32 zkVerificationKey;
}
```

