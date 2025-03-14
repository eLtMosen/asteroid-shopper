cmake_minimum_required(VERSION 3.6.0)

project(asteroid-shopper
	VERSION 1.0
	DESCRIPTION "A simple shopping list app for AsteroidOS")

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMFindQmlModule)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

add_executable(asteroid-shopper main.cpp resources.qrc)

target_link_libraries(asteroid-shopper PRIVATE
    AsteroidApp)

install(TARGETS asteroid-shopper DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES asteroid-shopper.desktop
        DESTINATION /usr/share/applications/)
install(FILES shopper.txt
        DESTINATION /home/ceres/)
