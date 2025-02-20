{ config, pkgs, lib, ... }:

with lib;

let
  pkg = pkgs.callPackage ../../pkgs/your_app {};
  cfg = config.services.your_app;
in
{
  # imports = [ paths of other modules ];

  # option declarations
  options = {
    services.your_app = {
      enable = mkEnableOption "your_app";
      # FIXME: Task 2.1: Declare options for the your_app service
      # use mkOption ! 
		port = mkOption {
    			type = lib.types.port;
    			default = 4444;
    			example = 5555;
    			description = lib.mdDoc "The port of the webserver.";
		};
	rpc = { 
		host = mkOption {
    			type = lib.types.str;
    			default = null;
    			example = "localhost";
    			description = lib.mdDoc "The host of the Bitcoin Core RPC server.";
		};
		port = mkOption {
    			type = lib.types.port;
    			default = 8333;
    			example = 12345;
    			description = lib.mdDoc "The port of the Bitcoin Core RPC server.";
		};
		user = mkOption {
    			type = lib.types.str;
    			default = null;
    			example = "username";
    			description = lib.mdDoc "A user for authentication with the Bitcoin Core RPC server";
		};
		password = mkOption {
    			type = lib.types.str;
    			default = null;
    			example = "super$secret";
    			description = lib.mdDoc "A password for authentication with the Bitcoin Core RPC server";
		};
	#	passwordFile = mkOption {
    	#		type = lib.types.path;
    	#		default = null;
    	#		example = "/run/secrets/your_app";
    	#		description = lib.mdDoc "A file containing the password for authentication with the Bitcoin Core RPC server";
	#	};
};
    };

  };

  # Option definitions: The place where we use the options declared above to
  # define options from other NixOS modules.
  #
  # `mkIf` makes the following option definitions conditional on the module being enabled.
  # See https://nixos.org/manual/nixos/stable/#sec-option-definitions-delaying-conditionals
  config = mkIf cfg.enable {

    # We define the systemd service called your_app.
    # NixOS takes care of creating the necessary service files.
    systemd.services.your_app_server = {
      description = "your_app server daemon";

      # systemd's `wantedBy` means that this service should be started for the
      # specified target to be reached. The `multi-user.target` normally defines
      # a system state where all network services are started up and the system
      # will accept logins
      wantedBy = [ "multi-user.target" ];
      # This should however only happen after the target `network-online` is
      # reached as we are using the network interfaces in our your_app
      after = [ "network-online.target" ];

      # The systemd service configuration
      # See https://www.freedesktop.org/software/systemd/man/systemd.service.html
      serviceConfig = {
        ExecStart = ''${pkg}/bin/your_app \
          --rpc-host ${cfg.rpc.host} \
          --rpc-port ${toString cfg.rpc.port} \
          --rpc-user ${cfg.rpc.user} \
          --rpc-password ${cfg.rpc.password}) \
          server ${toString cfg.port}
        '';
        # FIXME: Task 3.3: your_app hardening 
          #--rpc-pass ${builtins.readFile cfg.rpc.passwordFile}) \
      };
    };
  };
}
