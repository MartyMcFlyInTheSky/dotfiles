
fzf_hello_world() {
    echo "Hello World"
}

fzf_cmake_target() {
    cmake --build build --target $(cmake --build build --target help | awk '/^[a-zA-Z0-9_-]+:/ {print $1}' | sed 's/://' | fzf --prompt="Select a CMake target: ")
 }

fzf_exe() {
    find . -type f -executable | fzf --prompt="Select an executable to run: "
}
