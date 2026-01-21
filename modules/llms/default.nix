{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable Ollama as a systemd service with CUDA
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    environmentVariables = {
      # Prevent OOM on your 10GB card
      OLLAMA_MAX_LOADED_MODELS = "2";
      OLLAMA_NUM_PARALLEL = "1";
      # Keep models loaded for instant responses
      OLLAMA_KEEP_ALIVE = "-1";
      # Explicit CUDA device (if you have multiple GPUs)
      CUDA_VISIBLE_DEVICES = "0";
    };

    # Optional: Expose on network for other machines
    # listenAddress = "0.0.0.0:11434";
  };

  # You likely still want the CLI tools
  environment.systemPackages = [
    pkgs.ollama # The service includes this, but explicit is fine
    pkgs.gemini-cli
  ];

  # Ensure NVIDIA drivers are properly configured
  hardware.nvidia-container-toolkit.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
}
