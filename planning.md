```mermaid
flowchart TD
    A[Nvim Open]
    B[Nvim Close]
    C[File Create]
    %% from buffer, Ex, Oil, anything
    D[File Open]
    E[File Write]

    F[Get All File Paths]
    G[Get Links From Files]
    H[Determine File From Link]
    I[Add Files To DB]
    J[Add Links To DB]
    K[Remove Files From DB]
    L[Remove Links From DB]
    M[Hash File Contents]

    A --> F
    F --> M
    F --> G
    G --> H
    G --> I
    H --> J

    B --> F
    C --> I
    D --> M %% check against hash

    E --> G
```
