using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Threading.Tasks;

namespace CreateHTML
{
    class Program
    {
        static void Main(string[] args)
        {
            string main = File.ReadAllText(Directory.GetCurrentDirectory() + @"\main.html");
            int location = main.IndexOf("XXXXX_XXXXX");
            string firstHalf = main.Substring(0, location);
            string secondHalf = main.Substring(location+11);
            string levels = File.ReadAllText(Directory.GetCurrentDirectory() + @"\levels.lua");
            string images = File.ReadAllText(Directory.GetCurrentDirectory() + @"\images.lua");
            string sounds = File.ReadAllText(Directory.GetCurrentDirectory() + @"\sounds.lua");
            string core = File.ReadAllText(Directory.GetCurrentDirectory() + @"\core.lua");

            levels = RemoveFirstLinesWithRequire(levels);
            images = RemoveFirstLinesWithRequire(images);
            core = RemoveFirstLinesWithRequire(core);
            sounds = RemoveFirstLinesWithRequire(sounds);

            File.WriteAllText(Directory.GetCurrentDirectory() + @"\index.html",firstHalf + "\n\n" + levels + "\n\n" + images + "\n\n" + sounds + "\n\n" + core + "\n\n" + secondHalf);
        }
        static string RemoveFirstLinesWithRequire(string str)
        {
            var lines = str.Split(new[] { "\n" }, StringSplitOptions.None).ToList();
            if (lines[0].Length>8)
            {
                while (lines[0].Substring(0, 8) == "require ")
                {
                    lines.RemoveAt(0);
                    if (lines[0].Length < 8)
                    {
                        break;
                    }
                }
            }
            return String.Join("\n",lines.ToArray());
        }
    }
}
