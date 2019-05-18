using System;
using System.Diagnostics;
using System.Threading;
using kuranado.moe.DedicatedServerManager.Library;
using static System.Console;

namespace kuranado.moe.DedicatedServerManager.Server.MainModule
{
    class Program:IDedicatedServerModule
    {
        public static string ModuleName => "ServerMainModule";
        private static TraceLogs Logs { get; } = new TraceLogs(ModuleName);


        static void Main(string[] args)
        {
            Thread.CurrentThread.Name = "MainThread";

            Logs.AddTextListener("Test", "nya.log", SourceLevels.Verbose);
            Logs.Verbose("喵喵喵~~~");

            Pause();
        }


        [Conditional("DEBUG")]
        private static void Pause()
        {
            WriteLine("Press any key continue ... ");
            ReadKey(true);
        }
    }
}
