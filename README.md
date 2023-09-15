# fup-channels-bug

`flake-utils-plus` currently has a bug to do with finding NixPkgs channels. It checks
for `legacyPackages.x86_64-linux.nix` on each flake input to determine if it is NixPkgs.
This typically works, but some flakes may define `legacyPackages` which can cause issues
if they omit the system used for this check (among other issues).
[The fix](https://github.com/jakehamilton/flake-utils-plus) adds an additional check to
ensure that the entire attribute path `legacyPackages.x86_64-linux.nix` exists rather
than expecting `x86_64-linux` to always be defined. This avoids the error that would prevent
integrating tools like [agenix](https://github.com/ryantm/agenix/tree/main) in a flake that
uses `flake-utils-plus`.

## Reproduction

This repository contains two flakes. The first is a reproduction of the issue as it
happens today. The second uses a fixed version of `flake-utils-plus` to avoid the issue.

### Broken

1. Enter the `./broken` directory.
2. Run `nix flake show`.
3. An error will occur.

<details>
  <summary>View Error</summary>

```
path:/Users/short/work/fup-channels-bug/broken?lastModified=1694756427&narHash=sha256-PxAQQwmsRu1y0IwMjOSxvJWanyvirk2ZsXg65XeNzSs%3D
├───packages
│   ├───aarch64-darwin
error:
       … while calling the 'mapAttrs' builtin

         at /nix/store/i5ipw8rvj1fvdaj01bqzc0dpw9irrb4h-source/lib/mkFlake.nix:222:16:

          221|
          222|         pkgs = mapAttrs importChannel (mergeAny channelsFromFlakes channels);
             |                ^
          223|

       … in the left operand of the update (//) operator

         at /nix/store/i5ipw8rvj1fvdaj01bqzc0dpw9irrb4h-source/flake.nix:36:15:

           35|         mergeAny = lhs: rhs:
           36|           lhs // mapAttrs
             |               ^
           37|             (name: value:

       (stack trace truncated; use '--show-trace' to show the full trace)

       error: attribute 'x86_64-linux' missing

       at /nix/store/i5ipw8rvj1fvdaj01bqzc0dpw9irrb4h-source/lib/mkFlake.nix:208:74:

          207|         # For some odd reason `devshell` contains `legacyPackages` out put as well
          208|         channelFlakes = filterAttrs (_: value: value ? legacyPackages && value.legacyPackages.x86_64-linux ? nix) inputs;
             |                                                                          ^
          209|         channelsFromFlakes = mapAttrs (name: input: { inherit input; }) channelFlakes;
```

</details>

### Fixed

1. Enter the `./fixed` directory.
2. Run `nix flake show`.
3. The flake will display correctly and packages will be usable from agenix.

<details>
  <summary>View Output</summary>

```
path:/Users/short/work/fup-channels-bug/fixed?lastModified=1694756415&narHash=sha256-wNuGvg%2BorGpL0JGfT4sPDHssH4KXaY70VPo6ubtCR/A%3D
├───packages
│   ├───aarch64-darwin
│   │   └───agenix: package 'agenix-0.14.0'
│   ├───aarch64-linux
│   │   └───agenix omitted (use '--all-systems' to show)
│   ├───i686-linux
│   │   └───agenix omitted (use '--all-systems' to show)
│   ├───x86_64-darwin
│   │   └───agenix omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       └───agenix omitted (use '--all-systems' to show)
└───pkgs: unknown
```

</details>
