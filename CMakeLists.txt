

cmake_minimum_required(VERSION 3.16)
project(baziqbrowser LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick WebEngineQuick)

qt_add_executable(baziqbrowser
    main.cpp
    utils.h
)

target_link_libraries(baziqbrowser PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::WebEngineQuick
)

qt_add_qml_module(baziqbrowser
    URI BrowserUtils
    VERSION 1.0
    RESOURCE_PREFIX /
)

# Resources:
set(resources_resource_files
    "ApplicationRoot.qml"
    "BrowserDialog.qml"
    "BrowserWindow.qml"
    "DownloadView.qml"
    "FindBar.qml"
    "FullScreenNotification.qml"
)

qt_add_resources(baziqbrowser "resources"
    PREFIX
        "/"
    FILES
        ${resources_resource_files}
)

set(resources1_resource_files
    "icons/dialog-cancel.svg"
    "icons/dialog-ok-apply.svg"
    "icons/go-down.svg"
    "icons/go-next.svg"
    "icons/go-previous.svg"
    "icons/overflow-menu.svg"
    "icons/view-refresh.svg"
    "icons/list-add.svg"
    "icons/window-close.svg"
)

qt_add_resources(baziqbrowser "resources1"
    PREFIX
        "/icons"
    BASE
        "icons"
    FILES
        ${resources1_resource_files}
)

if(TARGET Qt::Widgets)
    target_link_libraries(baziqbrowser PUBLIC
        Qt::Widgets
    )
endif()

install(TARGETS baziqbrowser RUNTIME DESTINATION "/usr/bin")
