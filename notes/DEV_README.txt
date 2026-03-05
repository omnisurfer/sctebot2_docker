Resolved:

Look into https://github.com/realsenseai/librealsense/blob/v2.56.4/doc/distribution_linux.md to install manually from source as last resort.

CMake Warning at CMakeLists.txt:155 (find_package):
  Could not find a configuration file for package "realsense2" that is
  compatible with requested version "2.56.6".

  The following configuration files were considered but not accepted:

    /opt/ros/jazzy/lib/x86_64-linux-gnu/cmake/realsense2/realsense2Config.cmake, version: 2.56.4

Checked out realsense-ros tag 4.56.4 that seemed to build ok with above version of librealsense.
