// Recolor.cs - image helpers for retheme-swift (compiled at runtime by PowerShell Add-Type).
// Requires Windows + .NET Framework System.Drawing. No external dependencies.
// See docs/how-it-works.md for the algorithms.
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public static class Recolor
{
    static int[] Hex(string h) {
        h = h.TrimStart('#');
        return new int[] { Convert.ToInt32(h.Substring(0,2),16), Convert.ToInt32(h.Substring(2,2),16), Convert.ToInt32(h.Substring(4,2),16) };
    }

    // Find source color S and factor a such that p ~= a*S + (1-a)*white.
    static int Match(int r, int g, int b, List<int[]> src, double tol, out double aOut) {
        int best = -1; double bestErr = double.MaxValue; aOut = 0;
        for (int i = 0; i < src.Count; i++) {
            int[] s = src[i];
            double[] d = { 255 - s[0], 255 - s[1], 255 - s[2] };
            double[] q = { 255 - r, 255 - g, 255 - b };
            double dd = d[0]*d[0] + d[1]*d[1] + d[2]*d[2];
            if (dd < 1) continue;
            double a = (d[0]*q[0] + d[1]*q[1] + d[2]*q[2]) / dd;
            if (a < 0.18) continue;
            if (a > 1.0) a = 1.0;
            double err = 0;
            for (int c = 0; c < 3; c++) { double e = Math.Abs(q[c] - a*d[c]); if (e > err) err = e; }
            if (err < tol && err < bestErr) { bestErr = err; best = i; aOut = a; }
        }
        return best;
    }

    static Bitmap Load(string path) {
        using (var tmp = new Bitmap(path)) {
            var bmp = new Bitmap(tmp.Width, tmp.Height, PixelFormat.Format32bppArgb);
            using (var g = Graphics.FromImage(bmp)) { g.DrawImage(tmp, 0, 0, tmp.Width, tmp.Height); }
            return bmp;
        }
    }

    static byte[] Bytes(Bitmap bmp, out BitmapData data) {
        data = bmp.LockBits(new Rectangle(0,0,bmp.Width,bmp.Height), ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        byte[] buf = new byte[data.Stride * bmp.Height];
        Marshal.Copy(data.Scan0, buf, 0, buf.Length);
        return buf;
    }

    // Returns "visible pixels | matched pixels per source"
    public static string Analyze(string path, string[] srcHex, double tol) {
        var src = new List<int[]>(); foreach (var h in srcHex) src.Add(Hex(h));
        using (var bmp = Load(path)) {
            BitmapData data; byte[] buf = Bytes(bmp, out data);
            long vis = 0; long[] cnt = new long[src.Count];
            for (int i = 0; i < buf.Length; i += 4) {
                if (buf[i+3] < 10) continue; vis++;
                double a; int m = Match(buf[i+2], buf[i+1], buf[i], src, tol, out a);
                if (m >= 0 && a > 0.6) cnt[m]++;
            }
            bmp.UnlockBits(data);
            string s = bmp.Width + "x" + bmp.Height + " visible=" + vis;
            for (int k = 0; k < src.Count; k++) if (cnt[k] > 0) s += " " + srcHex[k] + "=" + cnt[k];
            return s;
        }
    }

    public static long Apply(string inPath, string outPath, string[] srcHex, string[] dstHex, double tol) {
        var src = new List<int[]>(); foreach (var h in srcHex) src.Add(Hex(h));
        var dst = new List<int[]>(); foreach (var h in dstHex) dst.Add(Hex(h));
        long changed = 0;
        using (var bmp = Load(inPath)) {
            BitmapData data; byte[] buf = Bytes(bmp, out data);
            for (int i = 0; i < buf.Length; i += 4) {
                if (buf[i+3] == 0) continue;
                double a; int m = Match(buf[i+2], buf[i+1], buf[i], src, tol, out a);
                if (m < 0) continue;
                int[] t = dst[m];
                buf[i+2] = (byte)Math.Round(a*t[0] + (1-a)*255);
                buf[i+1] = (byte)Math.Round(a*t[1] + (1-a)*255);
                buf[i]   = (byte)Math.Round(a*t[2] + (1-a)*255);
                changed++;
            }
            Marshal.Copy(buf, 0, data.Scan0, buf.Length);
            bmp.UnlockBits(data);
            ImageFormat fmt = outPath.ToLower().EndsWith(".png") ? ImageFormat.Png : ImageFormat.Jpeg;
            bmp.Save(outPath, fmt);
        }
        return changed;
    }

    // Place logo centered on a transparent canvas of w x h, fitted within maxW x maxH.
    public static string Canvas(string logoPath, string outPath, int w, int h, double fill) {
        using (var logo = Load(logoPath))
        using (var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb))
        using (var g = Graphics.FromImage(bmp)) {
            g.Clear(Color.Transparent);
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
            double s = Math.Min(w * fill / logo.Width, h * fill / logo.Height);
            int lw = (int)Math.Round(logo.Width * s), lh = (int)Math.Round(logo.Height * s);
            g.DrawImage(logo, (w - lw) / 2, (h - lh) / 2, lw, lh);
            bmp.Save(outPath, ImageFormat.Png);
            return lw + "x" + lh;
        }
    }

    // Turn every visible pixel right of xStart to white (keeps alpha) - for dark backgrounds.
    public static void WhiteFrom(string inPath, string outPath, int xStart) {
        using (var bmp = Load(inPath)) {
            BitmapData data; byte[] buf = Bytes(bmp, out data);
            for (int y = 0; y < bmp.Height; y++)
                for (int x = xStart; x < bmp.Width; x++) {
                    int i = y * data.Stride + x * 4;
                    if (buf[i+3] == 0) continue;
                    buf[i] = 255; buf[i+1] = 255; buf[i+2] = 255;
                }
            Marshal.Copy(buf, 0, data.Scan0, buf.Length);
            bmp.UnlockBits(data);
            bmp.Save(outPath, ImageFormat.Png);
        }
    }

    // First column (from left) after which a fully transparent vertical gap of >= minGap columns occurs.
    public static int FindGap(string path, int minGap) {
        using (var bmp = Load(path)) {
            BitmapData data; byte[] buf = Bytes(bmp, out data);
            bmp.UnlockBits(data);
            bool seen = false; int run = 0;
            for (int x = 0; x < bmp.Width; x++) {
                bool empty = true;
                for (int y = 0; y < bmp.Height; y++) if (buf[y*data.Stride + x*4 + 3] > 10) { empty = false; break; }
                if (!empty) { if (seen && run >= minGap) return x; seen = true; run = 0; }
                else run++;
            }
            return -1;
        }
    }

    // Top opaque bluish colors (b > r + 30), quantized to 6 bits/channel. Used to find leftover shades after a recolor.
    public static string Hist(string path, int top) {
        var d = new Dictionary<int,int>();
        using (var bmp = Load(path)) {
            BitmapData data; byte[] buf = Bytes(bmp, out data); bmp.UnlockBits(data);
            for (int i = 0; i < buf.Length; i += 4) {
                if (buf[i+3] < 250) continue;
                int b = buf[i], g = buf[i+1], r = buf[i+2];
                if (!(b > r + 30)) continue;
                int key = ((r>>2)<<16)|((g>>2)<<8)|(b>>2);
                int v; d.TryGetValue(key, out v); d[key] = v + 1;
            }
        }
        var list = new List<KeyValuePair<int,int>>(d); list.Sort((x,y)=>y.Value.CompareTo(x.Value));
        string s = "";
        for (int k = 0; k < Math.Min(top, list.Count); k++) {
            int key = list[k].Key;
            s += string.Format("#{0:X2}{1:X2}{2:X2}={3} ", ((key>>16)&255)<<2, ((key>>8)&255)<<2, (key&255)<<2, list[k].Value);
        }
        return s;
    }

    public static string Px(string path, int x, int y) {
        using (var bmp = Load(path)) { var c = bmp.GetPixel(x,y); return string.Format("A{0} #{1:X2}{2:X2}{3:X2}", c.A, c.R, c.G, c.B); }
    }

    public static void Crop(string inPath, string outPath, int x, int y, int w, int h) {
        using (var bmp = Load(inPath))
        using (var c = bmp.Clone(new Rectangle(x, y, w, h), PixelFormat.Format32bppArgb)) c.Save(outPath, ImageFormat.Png);
    }

    static void RgbToHsl(double r, double g, double b, out double h, out double s, out double l) {
        double max = Math.Max(r, Math.Max(g, b)), min = Math.Min(r, Math.Min(g, b));
        l = (max + min) / 2; double d = max - min;
        if (d < 1e-9) { h = 0; s = 0; return; }
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        if (max == r) h = (g - b) / d + (g < b ? 6 : 0); else if (max == g) h = (b - r) / d + 2; else h = (r - g) / d + 4;
        h *= 60;
    }
    static double H2(double p, double q, double t) {
        if (t < 0) t += 1; if (t > 1) t -= 1;
        if (t < 1.0/6) return p + (q - p) * 6 * t; if (t < 0.5) return q; if (t < 2.0/3) return p + (q - p) * (2.0/3 - t) * 6; return p;
    }
    static void HslToRgb(double h, double s, double l, out double r, out double g, out double b) {
        if (s < 1e-9) { r = g = b = l; return; }
        double q = l < 0.5 ? l * (1 + s) : l + s - l * s, p = 2 * l - q, hk = h / 360.0;
        r = H2(p, q, hk + 1.0/3); g = H2(p, q, hk); b = H2(p, q, hk - 1.0/3);
    }

    // Shift pixels whose hue is in [h0,h1] (with soft edges of `soft` degrees) to targetHue; satMul scales saturation.
    public static long HueShift(string inPath, string outPath, double h0, double h1, double soft, double minSat, double targetHue, double satMul) {
        long n = 0;
        using (var bmp = Load(inPath)) {
            BitmapData data; byte[] buf = Bytes(bmp, out data);
            for (int i = 0; i < buf.Length; i += 4) {
                if (buf[i+3] == 0) continue;
                double r = buf[i+2]/255.0, g = buf[i+1]/255.0, b = buf[i]/255.0, h, s, l;
                RgbToHsl(r, g, b, out h, out s, out l);
                if (s < minSat * 0.5) continue;
                double w = 1;
                if (h < h0) w = 1 - (h0 - h) / soft; else if (h > h1) w = 1 - (h - h1) / soft;
                if (w <= 0) continue;
                double ws = Math.Min(1, (s - minSat * 0.5) / (minSat * 0.5 + 1e-9)); w *= ws;
                if (w <= 0) continue;
                double nr, ng, nb; HslToRgb(targetHue, Math.Min(1, s * satMul), l, out nr, out ng, out nb);
                buf[i+2] = (byte)Math.Round(255 * (r + (nr - r) * w));
                buf[i+1] = (byte)Math.Round(255 * (g + (ng - g) * w));
                buf[i]   = (byte)Math.Round(255 * (b + (nb - b) * w));
                n++;
            }
            Marshal.Copy(buf, 0, data.Scan0, buf.Length); bmp.UnlockBits(data);
            bmp.Save(outPath, ImageFormat.Png);
        }
        return n;
    }

    public static void ToJpeg(string pngPath, string jpgPath, long quality) {
        using (var bmp = new Bitmap(pngPath)) {
            ImageCodecInfo enc = null; foreach (var c in ImageCodecInfo.GetImageEncoders()) if (c.MimeType == "image/jpeg") enc = c;
            var ps = new EncoderParameters(1); ps.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
            bmp.Save(jpgPath, enc, ps);
        }
    }

    // Cut light (white) artwork out of a darker background: white pixels with alpha from brightness.
    public static void ExtractLight(string inPath, string outPath, int x0, int y0, int w, int h, int lo, int hi) {
        using (var src = Load(inPath))
        using (var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
            for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
                var c = src.GetPixel(x0 + x, y0 + y);
                int m = Math.Min(c.R, Math.Min(c.G, c.B));
                int a = (int)Math.Round(255.0 * Math.Max(0, Math.Min(1, (m - lo) / (double)(hi - lo))));
                bmp.SetPixel(x, y, Color.FromArgb(a, 255, 255, 255));
            }
            bmp.Save(outPath, ImageFormat.Png);
        }
    }

    public static string Info(string path) {
        using (var bmp = Load(path)) {
            BitmapData data; byte[] buf = Bytes(bmp, out data);
            long transparent = 0, white = 0;
            for (int i = 0; i < buf.Length; i += 4) {
                if (buf[i+3] < 10) transparent++;
                else if (buf[i] > 245 && buf[i+1] > 245 && buf[i+2] > 245) white++;
            }
            bmp.UnlockBits(data);
            return bmp.Width + "x" + bmp.Height + " transparent=" + transparent + " white=" + white + " total=" + (bmp.Width*bmp.Height);
        }
    }
}
