with import <nixpkgs> {};

buildGoPackage rec {
  pname = "rclone";
  version = "master";

  src = fetchGit {
    url = "https://github.com/rclone/rclone";
    rev = "63128834dae262f4413130458f552737a867fac1";
  };

  goPackagePath = "github.com/rclone/rclone";

  subPackages = [ "." ];

  outputs = [ "bin" "out" "man" ];

  postInstall = ''
    install -D -m644 $src/rclone.1 $man/share/man/man1/rclone.1
  '';

  meta = with stdenv.lib; {
    description = "Command line program to sync files and directories to and from major cloud storage";
    homepage = https://rclone.org;
    license = licenses.mit;
    maintainers = with maintainers; [ danielfullmer ];
    platforms = platforms.all;
  };
}
