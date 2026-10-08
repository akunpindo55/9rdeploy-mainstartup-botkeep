# 9Router Botkeep bootstrap

Repo publik kecil ini berisi launcher dan manifest Node untuk Botkeep; source 9Router dan arsip runtime tidak disimpan di repo ini. Runtime diunduh dari rilis publik yang dipatok ke ukuran dan SHA-256, tanpa `npm install` atau build di server.

## Pasang di Botkeep

1. Buat server Node.js 22 dan impor repo `akunpindo55/9rdeploy-mainstartup-botkeep`, branch `main`.
2. Jika panel meminta **Project root di dalam repo**, pilih root/default (`.` atau kosong), karena `package.json` berada di root repo, bukan di subfolder `app/`.
3. Botkeep menaruh hasil checkout di folder server `/home/container/app`. Itu lokasi checkout di container Botkeep, bukan folder `app` di GitHub. Set Startup command tepat seperti ini:

   ```sh
   cd /home/container/app && npm start
   ```

   Jika File Manager server baru menunjukkan lokasi checkout yang berbeda, ganti hanya `/home/container/app` dengan lokasi checkout yang terlihat di sana.
4. Di Environment Botkeep, set `INITIAL_PASSWORD` sebagai Secret berisi sandi pilihanmu. Jangan masukkan sandi, `.env`, database, atau API key ke GitHub.
5. Simpan/Apply konfigurasi, lalu tekan Start. Tidak perlu menjalankan bootstrap terpisah: `npm start` memanggil `start.sh`, yang pada start pertama mengunduh, memeriksa, mengekstrak runtime, lalu menjalankannya. Saat restart, runtime yang sudah ada terdeteksi dan unduhan dilewati; command Startup tetap sama. Jangan jalankan `npm install`, `npm ci`, atau build di Botkeep.
6. Server menggunakan `SERVER_PORT` dan bind ke `0.0.0.0`. Pemeriksaan endpoint: `https://<host-Botkeep>/api/health` harus mengembalikan `{"ok":true}`.

Database disimpan terpisah di `/home/container/.9router`; bootstrap tidak menghapus atau menimpa folder data tersebut.

## Batas file dan ukuran

Repo bootstrap berisi **6 file** dan ukurannya di bawah 20 MB, sehingga impor repo tidak membawa source aplikasi yang besar.

Ada batasan penting: runtime yang diunduh berukuran **52.787.477 byte**. Setelah ekstraksi, arsip berisi **9.793 file biasa** dan 1.406 direktori (11.199 entri total). Loader mengambilnya langsung dari GitHub, bukan menyimpannya di repo bootstrap. Jadi metode ini memenuhi batas Botkeep 1.000 file/20 MB hanya jika batas itu berlaku untuk repo/berkas impor, bukan untuk file runtime hasil unduhan atau ekstraksi. Jika batas juga berlaku untuk runtime tersebut, jangan Start sebelum runtime dipangkas atau metode hostingnya diubah.

## Detail teknis

- Arsip runtime: `9r-standalone-runtime-d24d98a.tar.gz`; SHA-256 `b26dfe99645624d075e67b93df098c5457aeedc77942d395fae53101b086b574`.
- Bootstrap memeriksa ukuran dan SHA-256, mengekstrak ke staging, memeriksa file runtime, lalu memasangnya.
- Environment dari Botkeep tetap diprioritaskan; loader menambahkan fallback untuk membaca `.env` dari `/home/container`.
- Runtime berada di `/home/container/9r-standalone-d24d98a`; database berada di `/home/container/.9router`.
- Arsip unduhan dihapus setelah pemasangan berhasil untuk menghemat storage.
