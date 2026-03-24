self: super: {
  pear-desktop = super.pear-desktop.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ self.makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${old}/bin/pear-desktop $out/bin/pear-desktop \
        --set PULSE_PROP "application.identifier=YoutubeMusicClient"
    '';
  });

  equibop = super.equibop.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ self.makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${old}/bin/equibop $out/bin/equibop \
        --set PULSE_PROP "application.identifier=DiscordClient"
    '';
  });
}
