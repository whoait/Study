using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Drawing.Imaging;

namespace AddTextGIF
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string pathCSV = this.txtCSV.Text.ToString();
            string pathGIF = this.txtGIF.Text.ToString();
            string pathSaveFile = this.txtSaveto.Text.ToString();
            List<String> listCSV = new List<string>();
            listCSV = ReadCSV(pathCSV);
            AddTextToGIF(listCSV, pathGIF, pathSaveFile);




        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            txtCSV.Text = "";
            txtGIF.Text = "";
            txtSaveto.Text = "";
        }

        private void btnChooseCSV_Click(object sender, EventArgs e)
        {
            DialogResult result = this.openFileDialog1.ShowDialog();
            if (result == DialogResult.OK)
            {
                this.txtCSV.Text = this.openFileDialog1.FileName;
            }
        }

        private void btnChooseGIF_Click(object sender, EventArgs e)
        {
            DialogResult result = this.openFileDialog1.ShowDialog();
            if (result == DialogResult.OK)
            {
                this.txtGIF.Text = this.openFileDialog1.FileName;
            }

        }

        private void btnSaveTo_Click(object sender, EventArgs e)
        {
            DialogResult result = this.folderBrowserDialog1.ShowDialog();
            if (result == DialogResult.OK)
            {
                this.txtSaveto.Text = this.folderBrowserDialog1.SelectedPath;
            }

        }

        private List<String> ReadCSV(string pathCSV)
        {
            var csvReader = new StreamReader(File.OpenRead(pathCSV));
            List<String> listCSV = new List<string>();
            while (!csvReader.EndOfStream)
            {
                var line = csvReader.ReadLine();
                var values = line.Split(',');
                listCSV.Add(values[0]);
            }
            return listCSV;
        }
        private bool AddTextToGIF(List<string> listText, string pathFileGIF, string pathSaveFile)
        {   


            Image originalImg = Image.FromFile(pathFileGIF);
            Image[] frames = getFrames(originalImg); //get array frame of GIF
            PropertyItem item = originalImg.GetPropertyItem(0x5100); // FrameDelay in libgdiplus                                           
            int delay = (item.Value[0] + item.Value[1] * 256) * 10; // Time is in 1/100ths of a second
                                                                    //decode GIF
            
            for (int i = 0; i < listText.Count; i++)
            {
                AnimatedGifEncoder e = new AnimatedGifEncoder();
                e.Start(pathSaveFile);
                e.SetDelay(delay);
                pathSaveFile = pathSaveFile + "\\aaaaa"+i+".gif";
                e.SetRepeat(0);
                for (int j = 0; j < frames.Length; j++)
                {
                    Image temp = frames[j];
                    Graphics graphics = Graphics.FromImage(temp);
                    graphics.DrawString(listText[i], this.Font, Brushes.Red, 0, 0);
                    e.AddFrame(temp);
                }
                e.Finish();

            }
            
            return true;
        }

        private void Demo()
        {

            /* create Gif */
            //you should replace filepath
            String[] imageFilePaths = new String[] { "c:\\01.png", "c:\\02.png", "c:\\03.png" };
            String outputFilePath = "c:\\test.gif";
            AnimatedGifEncoder e = new AnimatedGifEncoder();
            e.Start(outputFilePath);
            e.SetDelay(500);
            //-1:no repeat,0:always repeat
            e.SetRepeat(0);
            for (int i = 0, count = imageFilePaths.Length; i < count; i++)
            {
                e.AddFrame(Image.FromFile(imageFilePaths[i]));
            }
            e.Finish();
            /* extract Gif */
            string outputPath = "c:\\";
            GifDecoder gifDecoder = new GifDecoder();
            gifDecoder.Read("c:\\test.gif");
            for (int i = 0, count = gifDecoder.GetFrameCount(); i < count; i++)
            {
                Image frame = gifDecoder.GetFrame(i);  // frame i
                frame.Save(outputPath + Guid.NewGuid().ToString() + ".png", ImageFormat.Png);
            }
        }

        Image[] getFrames(Image originalImg)
        {

            int numberOfFrames = originalImg.GetFrameCount(FrameDimension.Time);
            Image[] frames = new Image[numberOfFrames];
            for (int i = 0; i < numberOfFrames; i++)
            {
                originalImg.SelectActiveFrame(FrameDimension.Time, i);
                frames[i] = ((Image)originalImg.Clone());
            }
            return frames;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.txtCSV.Text = "C:\\Users\\whoai\\Desktop\\20151204_JISHAMEI_MASSHO.csv";
            this.txtGIF.Text = "C:\\Users\\whoai\\Desktop\\giphy.gif";
            this.txtSaveto.Text = "C:\\Users\\whoai\\Desktop";
        }


    }
}
