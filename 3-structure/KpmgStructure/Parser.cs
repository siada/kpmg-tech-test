using System.Collections.Generic;
using System.Text.Json;

namespace KpmgStructure
{
    public class Parser
    {
        public static object Parse(string document, string selector)
        {
            try
            {
                var doc = JsonDocument.Parse(document);
                var keys = selector.Split("/");
                var currentElement = doc.RootElement;
                foreach (var key in keys)
                {
                    currentElement = currentElement.GetProperty(key);
                }
                return currentElement;
            }
            catch (KeyNotFoundException)
            {
                return null;
            }
            catch
            {
                throw;
            }
        }
    }
}