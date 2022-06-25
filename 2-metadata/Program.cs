using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ec2_meta
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var obj = await GetMetadataAsJson();
            Console.WriteLine(JsonSerializer.Serialize(obj, new JsonSerializerOptions
            {
                WriteIndented = true
            }));
        }
        static HttpClient Client = new HttpClient();
        private static async Task<object> GetMetadataAsJson()
        {
            var url = "http://169.254.169.254/latest/";
            var o = await GetObject(url, "meta-data/");
            return o;
        }

        private static async Task<Dictionary<string, object>> GetObject(string url, params string[] paths)
        {
            var o = new Dictionary<string, object>();
            foreach (var item in paths)
            {
                string lItem = item;
                if (Regex.IsMatch(item, "^[0-9]+=")) // array based values 0=keyname etc.
                {
                    lItem = item.Substring(0, item.IndexOf('=')) + "/";
                }
                var r = await Client.GetAsync(url + lItem);
                var body = await r.Content.ReadAsStringAsync();
                var (isJson, inst) = IsJson(body);
                if (lItem.EndsWith("/"))
                {
                    o.Add(item, await GetObject(url + lItem, body.Split("\n")));
                }
                else if (isJson)
                {
                    o.Add(item, inst);
                }
                else
                {
                    o.Add(item, body);
                }
            }
            return o;
        }
        private static (bool result, object output) IsJson(string j)
        {
            try
            {
                var o = JsonSerializer.Deserialize<object>(j);
                return (o != null, o);
            }
            catch
            {
                return (false, null);
            }
        }
    }
}
