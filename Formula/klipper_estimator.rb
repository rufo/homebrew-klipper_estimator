class KlipperEstimator < Formula
  desc "Tool for estimating the length of a 3D print under the Klipper firmware"
  homepage "https://github.com/Annex-Engineering/klipper_estimator/"
  url "https://github.com/Annex-Engineering/klipper_estimator/archive/refs/tags/v2.0.6.tar.gz"
  sha256 "771c5a6538d2dd7a0be51a5d113e7eafd83abd594332877dfbd16c0164b30c03"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/rufo/klipper_estimator"
    sha256 cellar: :any_skip_relocation, monterey:     "9b86d84cf6ffda50b9c77d71c89c97392bb8e4a5d848f819743ab412610517fc"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "590336ba55e824d56bf854f8cc4ae242e9770aff0f685b10f73b7ebc04ce55a4"
  end

  depends_on "rust" => :build

  def install
    ENV["TOOL_VERSION"] = "v#{version}"
    chdir "tool" do
      system "cargo", "install", *std_cargo_args
    end
  end

  test do
    (testpath/"test.gcode").write("; ESTIMATOR_ADD_TIME 21")
    (testpath/"test_config.json").write('{
      "max_velocity": 250.0
      "max_acceleration": 3000.0,
      "max_accel_to_decel": 1500.0,
      "square_corner_velocity": 5.0,
      "instant_corner_velocity": 1.0,
      "move_checkers": [
        {
          "axis_limiter": {
            "axis": [
              0.0,
              0.0,
              1.0
            ],
            "max_velocity": 10.0,
            "max_accel": 30.0
          }
        },
        {
          "extruder_limiter": {
            "max_velocity": 66.52027009228607,
            "max_accel": 798.2432411074329
          }
        }
      ]
    }')

    test_command = <<~END
      #{bin}/klipper_estimator --config_file \
      #{testpath/"test_config.json"} estimate \
      #{testpath/"test.gcode"}
    END

    assert_includes shell_output(test_command), "Sequences"
  end
end
