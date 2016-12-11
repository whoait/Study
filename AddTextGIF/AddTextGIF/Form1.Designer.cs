namespace AddTextGIF
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.fileCSV = new System.Windows.Forms.Label();
            this.image = new System.Windows.Forms.Label();
            this.btnGen = new System.Windows.Forms.Button();
            this.btnClear = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.txtCSV = new System.Windows.Forms.TextBox();
            this.txtGIF = new System.Windows.Forms.TextBox();
            this.txtSaveto = new System.Windows.Forms.TextBox();
            this.btnChooseCSV = new System.Windows.Forms.Button();
            this.btnChooseGIF = new System.Windows.Forms.Button();
            this.btnSaveTo = new System.Windows.Forms.Button();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.folderBrowserDialog1 = new System.Windows.Forms.FolderBrowserDialog();
            this.folderBrowserDialog2 = new System.Windows.Forms.FolderBrowserDialog();
            this.SuspendLayout();
            // 
            // fileCSV
            // 
            this.fileCSV.AutoSize = true;
            this.fileCSV.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.fileCSV.Location = new System.Drawing.Point(27, 52);
            this.fileCSV.Name = "fileCSV";
            this.fileCSV.Size = new System.Drawing.Size(69, 16);
            this.fileCSV.TabIndex = 0;
            this.fileCSV.Text = "Text(CSV)";
            // 
            // image
            // 
            this.image.AutoSize = true;
            this.image.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.image.Location = new System.Drawing.Point(38, 103);
            this.image.Name = "image";
            this.image.Size = new System.Drawing.Size(29, 16);
            this.image.TabIndex = 1;
            this.image.Text = "GIF";
            // 
            // btnGen
            // 
            this.btnGen.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnGen.Location = new System.Drawing.Point(111, 228);
            this.btnGen.Name = "btnGen";
            this.btnGen.Size = new System.Drawing.Size(75, 23);
            this.btnGen.TabIndex = 2;
            this.btnGen.Text = "Gen";
            this.btnGen.UseVisualStyleBackColor = true;
            this.btnGen.Click += new System.EventHandler(this.button1_Click);
            // 
            // btnClear
            // 
            this.btnClear.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnClear.Location = new System.Drawing.Point(244, 228);
            this.btnClear.Name = "btnClear";
            this.btnClear.Size = new System.Drawing.Size(75, 23);
            this.btnClear.TabIndex = 3;
            this.btnClear.Text = "Clear";
            this.btnClear.UseVisualStyleBackColor = true;
            this.btnClear.Click += new System.EventHandler(this.btnClear_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(27, 151);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(54, 16);
            this.label1.TabIndex = 4;
            this.label1.Text = "Save to";
            // 
            // txtCSV
            // 
            this.txtCSV.Location = new System.Drawing.Point(102, 52);
            this.txtCSV.Name = "txtCSV";
            this.txtCSV.ReadOnly = true;
            this.txtCSV.Size = new System.Drawing.Size(217, 20);
            this.txtCSV.TabIndex = 5;
            // 
            // txtGIF
            // 
            this.txtGIF.Location = new System.Drawing.Point(102, 99);
            this.txtGIF.Name = "txtGIF";
            this.txtGIF.ReadOnly = true;
            this.txtGIF.Size = new System.Drawing.Size(217, 20);
            this.txtGIF.TabIndex = 6;
            // 
            // txtSaveto
            // 
            this.txtSaveto.Location = new System.Drawing.Point(102, 150);
            this.txtSaveto.Name = "txtSaveto";
            this.txtSaveto.ReadOnly = true;
            this.txtSaveto.Size = new System.Drawing.Size(217, 20);
            this.txtSaveto.TabIndex = 7;
            // 
            // btnChooseCSV
            // 
            this.btnChooseCSV.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnChooseCSV.Location = new System.Drawing.Point(313, 49);
            this.btnChooseCSV.Name = "btnChooseCSV";
            this.btnChooseCSV.Size = new System.Drawing.Size(75, 23);
            this.btnChooseCSV.TabIndex = 8;
            this.btnChooseCSV.Text = "Browse";
            this.btnChooseCSV.UseVisualStyleBackColor = true;
            this.btnChooseCSV.Click += new System.EventHandler(this.btnChooseCSV_Click);
            // 
            // btnChooseGIF
            // 
            this.btnChooseGIF.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnChooseGIF.Location = new System.Drawing.Point(313, 99);
            this.btnChooseGIF.Name = "btnChooseGIF";
            this.btnChooseGIF.Size = new System.Drawing.Size(75, 23);
            this.btnChooseGIF.TabIndex = 9;
            this.btnChooseGIF.Text = "Browse";
            this.btnChooseGIF.UseVisualStyleBackColor = true;
            this.btnChooseGIF.Click += new System.EventHandler(this.btnChooseGIF_Click);
            // 
            // btnSaveTo
            // 
            this.btnSaveTo.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSaveTo.Location = new System.Drawing.Point(313, 150);
            this.btnSaveTo.Name = "btnSaveTo";
            this.btnSaveTo.Size = new System.Drawing.Size(75, 23);
            this.btnSaveTo.TabIndex = 10;
            this.btnSaveTo.Text = "Browse";
            this.btnSaveTo.UseVisualStyleBackColor = true;
            this.btnSaveTo.Click += new System.EventHandler(this.btnSaveTo_Click);
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "openFileDialog1";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(455, 299);
            this.Controls.Add(this.btnSaveTo);
            this.Controls.Add(this.btnChooseGIF);
            this.Controls.Add(this.btnChooseCSV);
            this.Controls.Add(this.txtSaveto);
            this.Controls.Add(this.txtGIF);
            this.Controls.Add(this.txtCSV);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btnClear);
            this.Controls.Add(this.btnGen);
            this.Controls.Add(this.image);
            this.Controls.Add(this.fileCSV);
            this.Name = "Form1";
            this.Text = "AddTextGIF";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label fileCSV;
        private System.Windows.Forms.Label image;
        private System.Windows.Forms.Button btnGen;
        private System.Windows.Forms.Button btnClear;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtCSV;
        private System.Windows.Forms.TextBox txtGIF;
        private System.Windows.Forms.TextBox txtSaveto;
        private System.Windows.Forms.Button btnChooseCSV;
        private System.Windows.Forms.Button btnChooseGIF;
        private System.Windows.Forms.Button btnSaveTo;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog1;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog2;
    }
}

