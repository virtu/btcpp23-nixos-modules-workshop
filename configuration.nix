# This file is imported by vm.nix and rebuild.nix. Declare services here.

# This module is a function with the following arguments:
{
  pkgs, # nixpkgs
  modulesPath, # the path to the NixOS modules
  config, # the current system configuration
  ...
}:
let
  yourAppPort = 4242;
in
{
  imports = [
    # imports the your_app module
    ./modules/your_app
  ];

  ## Task 1
  services.bitcoind."regtest" = {
    enable = true;
    rpc = {
      port = 18444;
      users.workshop = {
        name = "workshop";
        # hashed password can be generated with https://github.com/bitcoin/bitcoin/blob/master/share/rpcauth/rpcauth.py
        # or https://jlopp.github.io/bitcoin-core-rpc-auth-generator/
        # Here, the password is "btcpp23berlin".
        passwordHMAC = "261106eacc7b4ff02628fbda556d65ec$bdc62ae101fbe7948c44b5475e2b56d046e326ce5d4f81b55e0861a66801226b";
      };
    };
    extraConfig = ''
      regtest=1
    '';
  };

  services.your_app = {
    # FIXME: Task 2.3: declare the options your_app options defined in 2.1
    # Use `yourAppPort` as port.
    enable = true;
    port = yourAppPort;
    rpc = {
	host = "localhost";
	port = config.services.bitcoind."regtest".rpc.port;
	user = config.services.bitcoind."regtest".rpc.users.workshop.name;
	password = "btcpp23berlin";
	#passwordFile = "./secret";
    };
  };

  # FIXME: 2.4: Open the firewall
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ config.services.your_app.port ];
};

  # Task 4
  virtualisation.oci-containers.containers = {
    "plaintext-hello" = {
      # FIXME: Task 4.2: declare `image` and `ports` options
        image = "nginxdemos/hello:plain-text";
        ports = ["8000:80"];
    };
  };

  # FIXME: Task 4.3: empty NixOS container
}
