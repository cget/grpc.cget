CGET_HAS_DEPENDENCY(zlib GITHUB madler/zlib VERSION v1.2.8 FINDNAME ZLIB)

CGET_HAS_DEPENDENCY(OpenSSL  REGISTRY VERSION OpenSSL_1_0_2h COMMIT_ID 32cb4b9b3)
CGET_HAS_DEPENDENCY(protobuf GITHUB jdavidberger/protobuf FINDNAME Protobuf OPTIONS -Dprotobuf_BUILD_TESTS:bool=OFF -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF COMMIT_ID 00f32d4)

SET(include_str)
list(APPEND include_str "include(\"${CGET_BIN_DIR}/load.cmake\")\n")
SET(BORINGSSL_ROOT_DIR "${CGET_OpenSSL_REPO_DIR}")
if(NOT MSVC)
    list(APPEND include_str "SET(_gRPC_BASELIB_LIBRARIES dl pthread CACHE STRING \"\" FORCE)\n")
else()    
    SET(BORINGSSL_ROOT_DIR "${CGET_OpenSSL_NUGET_DIR}/build/native")    
    string(REPLACE ";" " " OPENSSL_LIBRARIES "${OPENSSL_LIBRARIES}")   
    list(APPEND include_str "SET(OPENSSL_ROOT_DIR \"${OPENSSL_ROOT_DIR}\" CACHE STRING \"\" FORCE)\n")
    list(APPEND include_str "SET(_gRPC_SSL_LIBRARIES \"" "${OPENSSL_LIBRARIES}" "\" CACHE STRING \"\" FORCE)\n")
    list(APPEND include_str "SET(OPENSSL_INCLUDE_DIR \"${OPENSSL_INCLUDE_DIR}\" CACHE STRING \"\" FORCE)\n")
endif()

list(APPEND include_str "SET(BORINGSSL_ROOT_DIR \"${BORINGSSL_ROOT_DIR}\" CACHE STRING \"\" FORCE)\n")

file(WRITE "${CMAKE_CURRENT_LIST_DIR}/preload.cmake" ${include_str})

CGET_MESSAGE(3 "Writing to ${CMAKE_CURRENT_LIST_DIR}/preload.cmake")
CGET_HAS_DEPENDENCY(grpc GITHUB grpc/grpc NOSUBMODULES
  FINDNAME gRPC
  OPTIONS_FILE ${CMAKE_CURRENT_LIST_DIR}/preload.cmake
  OPTIONS 
  -DgRPC_INSTALL=ON
  -DgRPC_SSL_PROVIDER=package
  -DgRPC_PROTOBUF_PROVIDER=package
  -DPROTOBUF_ROOT_DIR=${CGET_protobuf_REPO_DIR}
  -DgRPC_ZLIB_PROVIDER=package
  COMMIT_ID 2a78d3d
  )

set(ARGS_NO_FIND_PACKAGE ON)
