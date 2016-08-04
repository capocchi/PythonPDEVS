add_custom_target(basic_tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${PYTHON_EXECUTABLE} "test_basic.py")
add_custom_target(mpi_tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${PYTHON_EXECUTABLE} "test_mpi.py")
add_custom_target(realtime_tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${PYTHON_EXECUTABLE} "test_realtime.py")

SET(DART_TESTING_TIMEOUT 1000)
add_test(NAME Basics
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
         COMMAND ${PYTHON_EXECUTABLE} "test_basic.py")
add_test(NAME MPI
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
         COMMAND ${PYTHON_EXECUTABLE} "test_mpi.py")
add_test(NAME Realtime
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
         COMMAND ${PYTHON_EXECUTABLE} "test_realtime.py")

set_tests_properties(Basics PROPERTIES FAIL_REGULAR_EXPRESSION "FAILED")
set_tests_properties(MPI PROPERTIES FAIL_REGULAR_EXPRESSION "FAILED")
set_tests_properties(Realtime PROPERTIES FAIL_REGULAR_EXPRESSION "FAILED")

