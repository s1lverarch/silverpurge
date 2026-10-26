# Maintainer: Silvercore (s1lverarch) <s1lv3rcore@proton.me>
# Website: https://s1lverarch.github.io/linuxdistro/

pkgname=silverpurge
pkgver=0.1.0
pkgrel=1
pkgdesc="SilverArch system cleanup: orphans, package cache, journal, trash and thumbnails (dry-run first)"
arch=('x86_64')
url="https://github.com/s1lverarch/silverpurge"
license=('GPL-3.0-only')
depends=('pacman' 'systemd')
makedepends=('nim')
optdepends=(
  'pacman-contrib: paccache for package cache cleanup'
)
source=("$pkgname-$pkgver.tar.gz::https://github.com/s1lverarch/$pkgname/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
  cd "$srcdir/$pkgname-$pkgver"
  nim c -d:release --opt:size -o:"$pkgname" src/$pkgname.nim
}

package() {
  cd "$srcdir/$pkgname-$pkgver"

  install -Dm755 "$pkgname" "$pkgdir/usr/bin/$pkgname"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 demo.tape "$pkgdir/usr/share/doc/$pkgname/demo.tape"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
