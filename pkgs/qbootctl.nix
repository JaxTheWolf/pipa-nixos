{
  qbootctl,
  pipa-headers,
}:
qbootctl.overrideAttrs (old: {
  pname = "qbootctl-pipa";

  buildInputs = (old.buildInputs or []) ++ [pipa-headers];

  NIX_CFLAGS_COMPILE = "-isystem ${pipa-headers}/include " + (old.NIX_CFLAGS_COMPILE or "");
})
