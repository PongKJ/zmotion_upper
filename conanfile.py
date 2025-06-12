from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout

class ConanApplication(ConanFile):
    package_type = "application"
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps"

    options = {
        "build_tests": [True, False],
    }

    default_options = {
        "build_tests": False,
        "qt/*:shared": True,
    }

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.user_presets_path = None
        tc.generate()

    def requirements(self):
        # requirements = self.conan_data.get("requirements", [])
        # for requirement in requirements:
        #     self.requires(requirement)
        self.requires("gtest/1.15.0")
        self.requires("spdlog/1.15.1")
        self.requires("jsoncpp/1.9.6")
        self.requires("dbg-macro/0.5.1")
        self.requires("boost/1.87.0")
        self.requires("cli11/2.4.2")
        self.requires("qt/6.6.3")

    def configure(self):
        if str(self.settings.os) == "Linux":
            self.options["qt"].with_x11 = False
