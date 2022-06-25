using KpmgStructure;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Text.Json;

namespace tests
{
    [TestClass]
    public class ParserTests
    {
        const string TestDocument = @"{""a"":{""b"":{""c"":""d""}}}";

        [TestMethod]
        public void Test_Should_Return_Null_On_Key_Not_Found()
        {
            try
            {
                var obj = Parser.Parse(TestDocument, "a/b/d");
                Assert.IsNull(obj);
            }
            catch
            {
                Assert.Fail();
            }
        }

        [TestMethod]
        public void Test_Successful_Parse_Level1()
        {
            var obj = Parser.Parse(TestDocument, "a");
            Assert.IsInstanceOfType(obj, typeof(JsonElement));
            Assert.AreEqual(@"{""b"":{""c"":""d""}}", obj.ToString());
        }

        [TestMethod]
        public void Test_Successful_Parse_Level2()
        {
            var obj = Parser.Parse(TestDocument, "a/b");
            Assert.IsInstanceOfType(obj, typeof(JsonElement));
            Assert.AreEqual(@"{""c"":""d""}", obj.ToString());
        }

        [TestMethod]
        public void Test_Successful_Parse_Level3()
        {
            var obj = Parser.Parse(TestDocument, "a/b/c");
            Assert.IsInstanceOfType(obj, typeof(JsonElement));
            Assert.AreEqual(@"d", obj.ToString());
        }

        [TestMethod]
        public void Test_Successful_Parse_Alternate()
        {
            var obj = Parser.Parse(@"{""x"":{""y"":{""z"":""a""}}}", "x/y/z");
            Assert.IsInstanceOfType(obj, typeof(JsonElement));
            Assert.AreEqual(@"a", obj.ToString());
        }
    }
}
