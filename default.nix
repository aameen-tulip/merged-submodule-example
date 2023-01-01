# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? builtins.getFlake "nixpkgs"
, lib     ? nixpkgs.lib
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
}: let

# ---------------------------------------------------------------------------- #

  text = ( lib.generators.toPretty {} ( lib.evalModules {
    modules = [
      ( { lib, config, options, specialArgs, ... } @ args: {
        options.foo = lib.mkOption { type = lib.types.int; default = 0; };
        options.bar = lib.mkOption {
          type = lib.types.submoduleWith {
            modules = [
              ( { lib, config, options, specialArgs, ... } @ args: {
                options.a = lib.mkOption { type = lib.types.int; default = 1; };
              } )
            ];
          };
        };
      } )

      ( { lib, config, options, specialArgs, ... } @ args: {
        options.bar = lib.mkOption {
          type = lib.types.submoduleWith {
            modules = [
              ( { lib, config, options, specialArgs, ... } @ args: {
                options.b = lib.mkOption { type = lib.types.int; default = 2; };
              } )
            ];
          };
        };
      } )

      ( { lib, config, options, specialArgs, ... } @ args: {
        config = {
          foo   = 4;
          bar.a = 5;
        };
      } )
    ];
  } ).config ) + "\n" ;

# ---------------------------------------------------------------------------- #

in derivation {
  inherit system text;
  name       = "dump-text";
  builder    = "${pkgsFor.bash}/bin/bash";
  passAsFile = ["text"];
  args       = ["-eu" "-o" "pipefail" "-c" ''
    while IFS= read -r line; do
      printf '%s\n' "$line" >> "$out";
    done <"$textPath"
  ''];
  preferLocalBuild = true;
  allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
