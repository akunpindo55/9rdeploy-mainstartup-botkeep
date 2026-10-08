# 9Router Botkeep bootstrap

Repo publik kecil ini hanya memuat loader dan startup untuk Botkeep; source 9Router dan arsip runtime tidak disalin ke repo ini. Runtime diunduh dari rilis publik yang dipatok ke ukuran dan SHA-256, tanpa `npm install` atau build di server.

## Pasang di Botkeep

1. Buat server Node.js 22 dan pilih repo `akunpindo55/9rdeploy-mainstartup-botkeep`, branch `main`.
2. Di Environment Botkeep, atur `INITIAL_PASSWORD` sebagai Secret berisi sandi pilihanmu. Jangan masukkan sandi, `.env`, database, atau API key ke GitHub.
3. Set Startup menjadi:

   ```sh
   cd /home/container && exec sh ./start.sh
   ```

4. Start server dan tunggu log Next.js menunjukkan `Ready`. `start.sh` otomatis menjalankan bootstrap hanya bila runtime belum ada. Pada restart berikutnya, bootstrap melewati unduhan dan runtime langsung dijalankan; Startup tidak perlu diganti setelah instalasi pertama.
5. Pastikan server memakai port `SERVER_PORT` dan bind ke `0.0.0.0`. Pemeriksaan endpoint: `https://<host-Botkeep>/api/health` harus mengembalikan `{"ok":true}`.

Database persisten disimpan di `/home/container/.9router`. Bootstrap tidak menghapus atau menimpa direktori data tersebut. Jangan jalankan `npm install`, `npm ci`, atau build pada server dengan storage terbatas.

## Batas file dan ukuran

Checkout repo bootstrap ini berisi **4 file** dan ukurannya jauh di bawah 20 MB, sehingga impor repo tidak membawa 1.298 file source aplikasi.

Ada batasan penting: runtime yang diunduh berukuran **52.787.477 byte** dan menghasilkan **11.199 file** saat diekstrak. Loader mengambilnya langsung dari GitHub, bukan menyimpannya di repo ini. Karena itu cara ini patuh hanya jika batas Botkeep 1.000 file/20 MB berlaku pada repo/berkas yang diimpor, bukan pada keseluruhan file runtime setelah diekstrak atau unduhan runtime. Jika limit Botkeep juga berlaku pada runtime hasil ekstraksi atau file unduhan server, arsip ini tidak memenuhi limit tersebut dan perlu runtime yang dibangun ulang/dipangkas terlebih dahulu.

## Detail teknis

- Rilis dipatok ke arsip `9r-standalone-runtime-d24d98a.tar.gz`, SHA-256 `b26dfe99645624d075e67b93df098c5457aeedc77942d395fae53101b086b574`.
- Bootstrap memeriksa SHA-256 dan ukuran, mengekstrak ke staging, memeriksa file runtime, lalu memasang secara atomik.
- Bootstrap menambahkan fallback pembacaan `.env` dari `/home/container`, sehingga Environment Botkeep dapat dibaca oleh runtime di subdirektori rilis. Variabel proses yang sudah disuntikkan tetap diprioritaskan.
- Runtime berada di `/home/container/9r-standalone-d24d98a`; data berada terpisah di `/home/container/.9router`.
- Arsip unduhan dihapus setelah instalasi berhasil untuk menghemat storage.
