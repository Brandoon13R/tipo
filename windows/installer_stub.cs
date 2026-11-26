using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Win32;

[assembly: AssemblyTitle("Brilliant - Instalador Oficial")]
[assembly: AssemblyDescription("Instalador y Desinstalador de Brilliant para Windows")]
[assembly: AssemblyProduct("Brilliant")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]

namespace BrilliantInstaller
{
    internal static class Program
    {
        private const string UninstallRegKeyPath = @"Software\Microsoft\Windows\CurrentVersion\Uninstall\Brilliant";

        public static string GetInstallDir()
        {
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            return Path.Combine(localAppData, "Programs", "Brilliant");
        }

        [STAThread]
        private static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            bool forceUninstall = false;
            if (args != null)
            {
                foreach (string arg in args)
                {
                    if (string.Equals(arg, "--uninstall", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(arg, "/uninstall", StringComparison.OrdinalIgnoreCase))
                    {
                        forceUninstall = true;
                        break;
                    }
                }
            }

            if (forceUninstall ||
                string.Equals(Path.GetFileName(Application.ExecutablePath), "Desinstalar_Brilliant.exe", StringComparison.OrdinalIgnoreCase))
            {
                DialogResult confirm = MessageBox.Show(
                    "¿Deseas desinstalar Brilliant y eliminar todos sus archivos y accesos directos de esta computadora?",
                    "Desinstalar Brilliant",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question
                );
                if (confirm == DialogResult.Yes)
                {
                    PerformUninstall();
                }
                return;
            }

            string existingExe = Path.Combine(GetInstallDir(), "Brilliant.exe");
            if (File.Exists(existingExe))
            {
                using (LauncherChoiceForm choiceForm = new LauncherChoiceForm())
                {
                    DialogResult result = choiceForm.ShowDialog();
                    if (result == DialogResult.Yes)
                    {
                        Application.Run(new InstallerForm());
                    }
                    else if (result == DialogResult.No)
                    {
                        PerformUninstall();
                    }
                }
                return;
            }

            Application.Run(new InstallerForm());
        }

        public static void RegisterUninstaller(string installDir, string targetExe, string uninstallerExe)
        {
            try
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(UninstallRegKeyPath))
                {
                    if (key == null) return;
                    key.SetValue("DisplayName", "Brilliant");
                    key.SetValue("DisplayVersion", "1.0.0");
                    key.SetValue("Publisher", "Brilliant Game");
                    key.SetValue("DisplayIcon", targetExe + ",0");
                    key.SetValue("InstallLocation", installDir);
                    key.SetValue("UninstallString", "\"" + uninstallerExe + "\" --uninstall");
                    key.SetValue("NoModify", 1, RegistryValueKind.DWord);
                    key.SetValue("NoRepair", 1, RegistryValueKind.DWord);
                }
            }
            catch { }
        }

        public static void PerformUninstall()
        {
            try
            {
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

                string desktopShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "Brilliant.lnk");
                string startMenuShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Programs), "Brilliant.lnk");
                string startMenuUninstallShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Programs), "Desinstalar Brilliant.lnk");

                if (File.Exists(desktopShortcut)) File.Delete(desktopShortcut);
                if (File.Exists(startMenuShortcut)) File.Delete(startMenuShortcut);
                if (File.Exists(startMenuUninstallShortcut)) File.Delete(startMenuUninstallShortcut);

                try
                {
                    Registry.CurrentUser.DeleteSubKeyTree(UninstallRegKeyPath, false);
                }
                catch { }

                string installDir = GetInstallDir();
                string currentExe = Path.GetFullPath(Application.ExecutablePath);
                bool runningFromInstallDir = currentExe.StartsWith(Path.GetFullPath(installDir), StringComparison.OrdinalIgnoreCase);

                if (Directory.Exists(installDir))
                {
                    if (!runningFromInstallDir)
                    {
                        Directory.Delete(installDir, true);
                    }
                    else
                    {
                        ProcessStartInfo cleanCmd = new ProcessStartInfo
                        {
                            FileName = "cmd.exe",
                            Arguments = "/C ping 127.0.0.1 -n 3 > nul & rmdir /s /q \"" + installDir + "\"",
                            WindowStyle = ProcessWindowStyle.Hidden,
                            CreateNoWindow = true,
                            UseShellExecute = false
                        };
                        Process.Start(cleanCmd);
                    }
                }

                MessageBox.Show(
                    "Brilliant se ha desinstalado por completo de esta computadora.",
                    "Brilliant desinstalado",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Ocurrió un error al desinstalar Brilliant:\n\n" + ex.Message,
                    "Error al desinstalar",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
        }
    }

    internal sealed class LauncherChoiceForm : Form
    {
        public LauncherChoiceForm()
        {
            Text = "Brilliant · Administrar instalación";
            Size = new Size(450, 225);
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

            Label title = new Label
            {
                Text = "Brilliant ya está instalado en esta PC",
                Font = new Font("Segoe UI", 12.5F, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 200, 255),
                Location = new Point(24, 20),
                Size = new Size(390, 28)
            };

            Label subtitle = new Label
            {
                Text = "¿Qué deseas hacer? Puedes actualizar/abrir el juego o desinstalarlo por completo de tu computadora.",
                Font = new Font("Segoe UI", 9.5F, FontStyle.Regular),
                ForeColor = Color.FromArgb(200, 210, 225),
                Location = new Point(24, 52),
                Size = new Size(390, 44)
            };

            Button playBtn = new Button
            {
                Text = "Actualizar y Jugar",
                Font = new Font("Segoe UI", 9.5F, FontStyle.Bold),
                BackColor = Color.FromArgb(0, 200, 255),
                ForeColor = Color.FromArgb(18, 22, 29),
                FlatStyle = FlatStyle.Flat,
                Location = new Point(24, 118),
                Size = new Size(185, 40),
                DialogResult = DialogResult.Yes
            };
            playBtn.FlatAppearance.BorderSize = 0;

            Button uninstallBtn = new Button
            {
                Text = "Desinstalar de esta PC",
                Font = new Font("Segoe UI", 9.5F, FontStyle.Bold),
                BackColor = Color.FromArgb(220, 53, 69),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Location = new Point(225, 118),
                Size = new Size(185, 40),
                DialogResult = DialogResult.No
            };
            uninstallBtn.FlatAppearance.BorderSize = 0;

            Controls.Add(title);
            Controls.Add(subtitle);
            Controls.Add(playBtn);
            Controls.Add(uninstallBtn);
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
            string installDir = Program.GetInstallDir();

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
            string uninstallerExe = Path.Combine(installDir, "Desinstalar_Brilliant.exe");

            try
            {
                File.Copy(Application.ExecutablePath, uninstallerExe, true);
            }
            catch { }

            string desktopShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "Brilliant.lnk");
            string startMenuShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Programs), "Brilliant.lnk");
            string startMenuUninstallShortcut = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Programs), "Desinstalar Brilliant.lnk");

            CreateShortcut(desktopShortcut, targetExe, installDir, "Brilliant - Juego de estrategia numerica");
            CreateShortcut(startMenuShortcut, targetExe, installDir, "Brilliant - Juego de estrategia numerica");
            CreateShortcut(startMenuUninstallShortcut, uninstallerExe, installDir, "Desinstalar Brilliant de esta computadora");

            Program.RegisterUninstaller(installDir, targetExe, uninstallerExe);

            return targetExe;
        }

        private static void CreateShortcut(string shortcutPath, string targetPath, string workingDir, string description)
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
                scType.InvokeMember("Description", BindingFlags.SetProperty, null, shortcut, new object[] { description });
                scType.InvokeMember("Save", BindingFlags.InvokeMethod, null, shortcut, null);
            }
            catch { }
        }
    }
}
