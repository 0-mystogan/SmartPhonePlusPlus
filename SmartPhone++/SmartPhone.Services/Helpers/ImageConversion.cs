using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SmartPhone.Services.Helpers
{
    public class ImageConversion
    {
        public static byte[] HexToByteArray(string hex)
        {
            hex = hex.Replace("0x", "");
            byte[] bytes = new byte[hex.Length / 2];
            for (int i = 0; i < bytes.Length; i++)
            {
                bytes[i] = Convert.ToByte(hex.Substring(i * 2, 2), 16);
            }
            return bytes;
        }


        public static string ConvertImageToBase64String(string folder, string imageName)
        {
            var imageBytes = ConvertImageToByteArray(folder, imageName);
            return imageBytes != null ? Convert.ToBase64String(imageBytes) : null;
        }



        public static byte[] ConvertImageToByteArray(string folder, string imageName)
        {
            string currentDirectory = Directory.GetCurrentDirectory();
            Console.WriteLine($"Current directory: {currentDirectory}");
            Console.WriteLine($"Looking for image: {imageName}");

            try
            {
                // Try multiple base paths for Docker environment
                var basePaths = new[]
                {
                    Path.Combine(currentDirectory, folder),
                    Path.Combine("/app", "Assets"),
                    Path.Combine("/app", "SmartPhone.WebAPI", "Assets"),
                    Path.Combine(AppContext.BaseDirectory, folder),
                    Path.Combine(AppContext.BaseDirectory, "SmartPhone.WebAPI", folder)
                };
                
                foreach (var basePath in basePaths)
                {
                    if (!Directory.Exists(basePath)) continue;
                    
                    // First try exact match
                    string exactPath = Path.Combine(basePath, imageName);
                    Console.WriteLine($"Trying exact path: {exactPath}");
                    
                    if (File.Exists(exactPath))
                    {
                        Console.WriteLine($"Image found: {exactPath}");
                        return File.ReadAllBytes(exactPath);
                    }
                    
                    // Try case-insensitive search
                    try
                    {
                        var files = Directory.GetFiles(basePath)
                            .Where(f => Path.GetFileName(f).Equals(imageName, StringComparison.OrdinalIgnoreCase))
                            .ToArray();
                        
                        if (files.Any())
                        {
                            string foundPath = files.First();
                            Console.WriteLine($"Image found with different case: {foundPath}");
                            return File.ReadAllBytes(foundPath);
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error searching in directory {basePath}: {ex.Message}");
                    }
                }
                
                Console.WriteLine($"Image file not found in any location: {imageName}");
                return null;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error reading image file: {ex.Message}");
                return null;
            }
        }
    }
}
