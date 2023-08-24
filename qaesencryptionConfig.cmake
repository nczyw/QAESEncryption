cmake_minimum_required(VERSION 3.5)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QTAES_ENABLE_AESNI  ON)

#是否编译成库
set(BuildQAESEncryptionLib ON)


include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/inc)
include_directories(${CMAKE_CURRENT_LIST_DIR}/inc/aesni)
include_directories(${CMAKE_CURRENT_LIST_DIR}/src)

find_package(QT NAMES Qt6 Qt5)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)

set(QAESEncryption_Headers
        ${CMAKE_CURRENT_LIST_DIR}/inc/qaesencryption.h
    )

set(QAESEncryption_Sources
        ${CMAKE_CURRENT_LIST_DIR}/src/qaesencryption.cpp

    )
if(QTAES_ENABLE_AESNI)
    message("Enable AES-NI")
    add_definitions(-DUSE_INTEL_AES_IF_AVAILABLE)
    set(AESNI
        ${CMAKE_CURRENT_LIST_DIR}/inc/aesni/aesni-enc-cbc.h
        ${CMAKE_CURRENT_LIST_DIR}/inc/aesni/aesni-enc-ecb.h
        ${CMAKE_CURRENT_LIST_DIR}/inc/aesni/aesni-key-exp.h
        ${CMAKE_CURRENT_LIST_DIR}/inc/aesni/aesni-key-init.h
    )
else()
    set(AESNI "")
endif()
set(QAESEncryption_Project
    ${AESNI}
    ${QAESEncryption_Headers}
    ${QAESEncryption_Sources}
    )

#直接像上层传递工程文件
if(BuildQAESEncryptionLib)
    #编译成库
    add_library(QAESEncryption_lib
            ${QAESEncryption_Project}
    )
    #给库添加编译选项
    if(QTAES_ENABLE_AESNI)
        include(CheckCXXCompilerFlag)
        check_cxx_compiler_flag(-maes CXX_COMPILER_HAS_FLAG_MAES)
        target_compile_options(QAESEncryption_lib
            PRIVATE
            $<$<BOOL:${CXX_COMPILER_HAS_FLAG_MAES}>:-maes>
        )
    endif()
    #给库添加相应依赖
    target_link_libraries(QAESEncryption_lib PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)
    #在顶层使用target_link_libraries加载该库
endif()
#[[  如果不编译成库时，需要在顶层cmake中添加如下编译器选项
if(QTAES_ENABLE_AESNI)
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag(-maes CXX_COMPILER_HAS_FLAG_MAES)
    target_compile_options(${CMAKE_PROJECT_NAME}
        PRIVATE
        $<$<BOOL:${CXX_COMPILER_HAS_FLAG_MAES}>:-maes>
    )
endif()
]]

