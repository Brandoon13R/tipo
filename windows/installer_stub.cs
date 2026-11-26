using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;

[assembly: AssemblyTitle("Brilliant - Instalador Oficial")]
[assembly: AssemblyDescription("Instalador automatico de Brilliant para Windows")]
[assembly: AssemblyProduct("Brilliant")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]

namespace BrilliantInstaller
{
    internal static class Program
    {
        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new InstallerForm());
        }
    }

    internal sealed class InstallerForm : Form
    {
        private readonly Label _titleLabel;
        private readonly Label _statusLabel;
        private readonly ProgressBar _progressBar;

        public InstallerForm()
        {
            Text = "Brilliant · Instalador";
            Size = new Size(440, 175);
            FormBorderStyle = FormBorderStyle.FixedDialog;
            StartPosition = FormStartPosition.CenterScreen;
            MaximizeBox = false;
            MinimizeBox = false;
            BackColor = Color.FromArgb(18, 22, 29);
            ForeColor = Color.FromArgb(226, 232, 240);

            try
            {
                Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
            }
            catch { }

            _titleLabel = new Label
            {
                Text = "Instalando Brilliant...",
                Font = new Font("Segoe UI", 13F, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 200, 255),
                AutoSize = false,
                Location = new Point(24, 20),
                Size = new Size(380, 28)
            };

            _statusLabel = new Label
            {
                Text = "Preparando archivos del juego y accesos directos...",
                Font = new Font("Segoe UI", 9.5F, FontStyle.Regular),
                ForeColor = Color.FromArgb(200, 210, 225),
                AutoSize = false,
                Location = new Point(24, 54),
                Size = new Size(380, 24)
            };

            _progressBar = new ProgressBar
            {
                Style = ProgressBarStyle.Marquee,
                MarqueeAnimationSpeed = 25,
                Location = new Point(24, 90),
                Size = new Size(376, 22)
            };

            Controls.Add(_titleLabel);
            Controls.Add(_statusLabel);
            Controls.Add(_progressBar);

            Shown += OnFormShown;
        }

        private async void OnFormShown(object sender, EventArgs e)
        {
            try
            {
                string exeToLaunch = await Task.Run(() => InstallGame());
                _statusLabel.Text = "¡Instalación completada! Iniciando Brilliant...";
                await Task.Delay(350);

                if (File.Exists(exeToLaunch))
                {
                    ProcessStartInfo psi = new ProcessStartInfo
                    {
                        FileName = exeToLaunch,
                        WorkingDirectory = Path.GetDirectoryName(exeToLaunch),
                        UseShellExecute = true
                    };
                    Process.Start(psi);
                }
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Ocurrió un problema al instalar Brilliant:\n\n" + ex.Message,
                    "Error de instalación",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
                Close();
            }
        }

        private static string InstallGame()
        {
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string installDir = Path.Combine(localAppData, "Programs", "Brilliant");

            foreach (Process proc in Process.GetProcessesByName("Brilliant"))
            {
                try
                {
                    if (proc.Id != Process.GetCurrentProcess().Id)
                    {
                        proc.Kill();
                        proc.WaitForExit(2000);
                    }
                }
                catch { }
            }

            if (!Directory.Exists(installDir))
            {
                Directory.CreateDirectory(installDir);
            }

            Assembly asm = Assembly.GetExecutingAssembly();
            using (Stream payloadStream = asm.GetManifestResourceStream("BrilliantPayload.zip"))
            {
                if (payloadStream == null)
                {
                    throw new InvalidOperationException("No se encontró el paquete integrado de Brilliant dentro del instalador.");
                }

                using (ZipArchive archive = new ZipArchive(payloadStream, ZipArchiveMode.Read))
                {
                    foreach (ZipArchiveEntry entry in archive.Entries)
                    {
                        string fullPath = Path.Combine(installDir, entry.FullName.Replace('/', Path.DirectorySeparatorChar));
                        if (string.IsNullOrEmpty(entry.Name))
                        {
                            Directory.CreateDirectory(fullPath);
                            continue;
                        }

                        string parentDir = Path.GetDirectoryName(fullPath);
                        if (!string.IsNullOrEmpty(parentDir) && !Directory.Exists(parentDir))
                        {
                            Directory.CreateDirectory(parentDir);
                        }

                        entry.ExtractToFile(fullPath, true);
                    }
                }
            }

            string targetExe = Path.Combine(installDir, "Brilliant.exe");
            string desktopShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "Brilliant.lnk");
            string startMenuShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Programs), "Brilliant.lnk");

            CreateShortcut(desktopShortcut, targetExe, installDir);
            CreateShortcut(startMenuShortcut, targetExe, installDir);

            return targetExe;
        }

        private static void CreateShortcut(string shortcutPath, string targetPath, string workingDir)
        {
            try
            {
                Type shellType = Type.GetTypeFromProgID("WScript.Shell");
                if (shellType == null) return;
                object shell = Activator.CreateInstance(shellType);
                object shortcut = shellType.InvokeMember(
                    "CreateShortcut",
                    BindingFlags.InvokeMethod,
                    null,
                    shell,
                    new object[] { shortcutPath }
                );
                Type scType = shortcut.GetType();
                scType.InvokeMember("TargetPath", BindingFlags.SetProperty, null, shortcut, new object[] { targetPath });
                scType.InvokeMember("WorkingDirectory", BindingFlags.SetProperty, null, shortcut, new object[] { workingDir });
                scType.InvokeMember("IconLocation", BindingFlags.SetProperty, null, shortcut, new object[] { targetPath + ",0" });
                scType.InvokeMember("Description", BindingFlags.SetProperty, null, shortcut, new object[] { "Brilliant - Juego de estrategia numerica" });
                scType.InvokeMember("Save", BindingFlags.InvokeMethod, null, shortcut, null);
            }
            catch { }
        }
    }
}
