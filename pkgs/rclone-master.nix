with import <nixpkgs> {};

buildGoPackage rec {
  pname = "rclone-master";
  version = "master";

  src = fetchGit {
    url = "https://github.com/rclone/rclone";
    rev = "1ba5e991526db5ec0242f4f51fb35688f4a0e71c";
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
