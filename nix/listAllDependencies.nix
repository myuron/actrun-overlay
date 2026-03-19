# Patched version of moonbit-overlay's listAllDependencies.nix
# Fix 1: use "${head.name}" instead of head.name for attr key (Nix syntax bug)
# Fix 2: dedup by name+version instead of name only, so all needed versions are cached
{ lib, parseMoonIndex }:
let

  # Returns attrset<name: string, index-entry: attrset>
  listAllDependencies =
    {
      registryIndexSrc,
      unresolvedDependencies, # list<{name: string, version: string}>
      resolvedDependencies ? { }, # attrset<"name@version": true>
    }:
    if builtins.length unresolvedDependencies == 0 then
      [ ]
    else
      let
        head = builtins.head unresolvedDependencies;
        tail = builtins.tail unresolvedDependencies;
        key = "${head.name}@${head.version}";
        headIndexRecords = builtins.readFile "${registryIndexSrc}/user/${head.name}.index";
        headIndex = parseMoonIndex headIndexRecords;
        headDependency = headIndex.${head.version};
        resolvedDependencies' = resolvedDependencies // {
          "${key}" = true;
        };
        unresolvedDependencies' =
          tail
          ++ (lib.mapAttrsToList (name: version: { inherit name version; }) (headDependency.deps or { }));
        next = listAllDependencies {
          inherit registryIndexSrc;
          unresolvedDependencies = unresolvedDependencies';
          resolvedDependencies = resolvedDependencies';
        };
      in
      if builtins.hasAttr key resolvedDependencies then next else next ++ [ headDependency ];
in
listAllDependencies
