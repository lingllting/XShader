using UnityEngine;
using UnityEditor;
using Excel;
using System.Data;
using System.IO;
using System.Collections.Generic;
using OfficeOpenXml;

public class ExcelAccess
{
    public static string ExcelName = "Book.xlsx";
   
    /// <summary>
    /// 读取 Excel 需要添加 Excel; System.Data;
    /// </summary>
    /// <param name="sheet"></param>
    /// <returns></returns>
    static DataRowCollection ReadExcel(string sheet)
    {
        FileStream stream = File.Open(FilePath(ExcelName), FileMode.Open, FileAccess.Read, FileShare.Read);
        IExcelDataReader excelReader = ExcelReaderFactory.CreateOpenXmlReader(stream);

        DataSet result = excelReader.AsDataSet();
        //int columns = result.Tables[0].Columns.Count;
        //int rows = result.Tables[0].Rows.Count;
        return result.Tables[sheet].Rows;
    }

    /// <summary>
    /// 读取 Excel 需要添加 OfficeOpenXml;
    /// </summary>
    public static void WriteExcel(List<EffectPerformanceReport> reportList, string outputDir)
    {
        //string outputDir = EditorUtility.SaveFilePanel("Save Excel", "", "New Resource", "xlsx");
        FileInfo newFile = new FileInfo(outputDir);
        if (newFile.Exists)
        {
            newFile.Delete();  // ensures we create a new workbook
            newFile = new FileInfo(outputDir);
        }
        using (ExcelPackage package = new ExcelPackage(newFile))
        {
            // add a new worksheet to the empty workbook
            ExcelWorksheet worksheet = package.Workbook.Worksheets.Add("Sheet1");
            //Add the headers
            worksheet.Cells[1, 1].Value = "特效路径";
            worksheet.Cells[1, 2].Value = "加载时间";
            worksheet.Cells[1, 3].Value = "实例化时间";
            worksheet.Cells[1, 4].Value = "单帧最大时间";
            worksheet.Cells[1, 5].Value = "最耗时N帧平均时间";
            worksheet.Cells[1, 6].Value = "激活的渲染器数量";
            worksheet.Cells[1, 7].Value = "发射器数量";
            worksheet.Cells[1, 8].Value = "不同材质个数";
            worksheet.Cells[1, 9].Value = "最多粒子个数";
            worksheet.Cells[1, 10].Value = "贴图内存KB";

            for (int i = 0; i < reportList.Count; i++ )
            {
                worksheet.Cells[i + 2, 1].Value = reportList[i].Path;
                worksheet.Cells[i + 2, 2].Value = reportList[i].LoadTime;
                worksheet.Cells[i + 2, 3].Value = reportList[i].InstantiateTime;
                worksheet.Cells[i + 2, 4].Value = reportList[i].MaxRenderTime;
                worksheet.Cells[i + 2, 5].Value = reportList[i].TopAverageRenderTime;
                worksheet.Cells[i + 2, 6].Value = reportList[i].ActiveRendererCount;
                worksheet.Cells[i + 2, 7].Value = reportList[i].TotalParticleSystemCount;
                worksheet.Cells[i + 2, 8].Value = reportList[i].MaterialCount;
                worksheet.Cells[i + 2, 9].Value = reportList[i].MaxParticleCount;
                worksheet.Cells[i + 2, 10].Value = reportList[i].TextureMemoryBytes;
            }
            package.Save();
        }
    }
    public static string FilePath(string name)
    {
        return Application.dataPath+"/" + name;
    }

}

