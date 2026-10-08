# 9Router Botkeep bootstrap

Repo publik kecil ini berisi launcher dan manifest Node untuk Botkeep; source 9Router dan arsip runtime tidak disimpan di repo ini. Runtime diunduh dari rilis publik yang dipatok ke ukuran dan SHA-256, tanpa `npm install` atau build di server.

## Pasang di Botkeep

1. Buat server Node.js 22.
2. Di bagian GitHub, pilih repo `akunpindo55/9rdeploy-mainstartup-botkeep`, branch `main`.
3. Set **Project root** ke root repo (`.`), yaitu direktori yang berisi `package.json`. Jangan pilih subfolder `app/`; tidak ada folder itu di repo.
4. Di Environment Botkeep, atur `INITIAL_PASSWORD` sebagai Secret berisi sandi pilihanmu. Jangan simpan sandi, `.env`, database, atau API key di GitHub.
5. Isi **Startup command** hanya dengan:

   ```sh
   npm start
   ```

   Botkeep menjalankannya dari Project root yang dipilih. `package.json` menjalankan `sh ./start.sh`; `start.sh` memanggil `bootstrap.sh` otomatis saat runtime belum terpasang, lalu menjalankan 9Router. Jadi jangan tambahkan `cd /home/container/app`, dan jangan jalankan bootstrap, `npm install`, `npm ci`, atau build sebagai command terpisah.
6. Simpan/Apply konfigurasi lalu Start. Start pertama mengunduh, memeriksa, dan mengekstrak runtime. Pada restart, runtime yang sudah ada dipakai kembali tanpa unduhan ulang. Server memakai `SERVER_PORT` dan bind ke `0.0.0.0`.
7. Setelah Console menunjukkan server siap, cek `https://<host-Botkeep>/api/health`; hasil yang diharapkan `{"ok":true}`.

Data database disimpan terpisah di `/home/container/.9router`; bootstrap tidak menghapus atau menimpa folder data tersebut.

## Batas file dan ukuran

Repo bootstrap berisi **6 file** dan ukurannya di bawah 20 MB, sehingga impor repo tidak membawa source aplikasi yang besar.

Ada batasan penting: runtime yang diunduh berukuran **52.787.477 byte**. Setelah ekstraksi, arsip berisi **9.793 file biasa** dan 1.406 direktori (11.199 entri total). Loader mengambilnya langsung dari GitHub, bukan menyimpannya di repo bootstrap. Jadi metode ini memenuhi batas Botkeep 1.000 file/20 MB hanya jika batas itu berlaku untuk repo/berkas impor, bukan untuk file runtime hasil unduhan atau ekstraksi. Jika batas juga berlaku pada runtime tersebut, jangan Start sebelum runtime dipangkas atau metode hostingnya diubah.

## Detail teknis

- Arsip runtime: `9r-standalone-runtime-d24d98a.tar.gz`; SHA-256 `b26dfe99645624d075e67b93df098c5457aeedc77942d395fae53101b086b574`.
- Bootstrap memeriksa ukuran dan SHA-256, mengekstrak ke staging, memeriksa file runtime, lalu memasangnya.
- Environment dari Botkeep tetap diprioritaskan; loader menambahkan fallback untuk membaca `.env` dari `/home/container`.
- Runtime berada di `/home/container/9r-standalone-d24d98a`; database berada di `/home/container/.9router`.
- Arsip unduhan dihapus setelah pemasangan berhasil untuk menghemat storage.
