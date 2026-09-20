#pragma once
#include <stdint.h>

#define SAM_NG_PROTOCOL_VERSION 1u
#define SAM_NG_MAX_PATH_CHARS 520u
#define SAM_NG_MAX_HOST_CHARS 256u

typedef enum SAM_NG_DIRECTION {
    SamNgOutboundConnect = 1,
    SamNgInboundAccept = 2
} SAM_NG_DIRECTION;

typedef enum SAM_NG_DECISION {
    SamNgUseSavedPolicy = 0,
    SamNgAllowOnce = 1,
    SamNgAllowRemember = 2,
    SamNgBlockOnce = 3,
    SamNgBlockRemember = 4
} SAM_NG_DECISION;

typedef struct SAM_NG_REQUEST {
    uint32_t version;
    uint32_t size;
    uint64_t request_id;
    uint64_t process_id;
    uint32_t direction;
    uint32_t protocol;
    uint8_t local_address[16];
    uint8_t remote_address[16];
    uint16_t local_port;
    uint16_t remote_port;
    uint32_t timeout_ms;
    wchar_t image_path[SAM_NG_MAX_PATH_CHARS];
} SAM_NG_REQUEST;

typedef struct SAM_NG_RESPONSE {
    uint32_t version;
    uint32_t size;
    uint64_t request_id;
    uint32_t decision;
    uint32_t reserved;
} SAM_NG_RESPONSE;
