
namespace Microcontroladores_II
{
    partial class Form1
    {
        /// <summary>
        /// Variable del diseñador necesaria.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpiar los recursos que se estén usando.
        /// </summary>
        /// <param name="disposing">true si los recursos administrados se deben desechar; false en caso contrario.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código generado por el Diseñador de Windows Forms

        /// <summary>
        /// Método necesario para admitir el Diseñador. No se puede modificar
        /// el contenido de este método con el editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.SPort = new System.IO.Ports.SerialPort(this.components);
            this.label1 = new System.Windows.Forms.Label();
            this.VoltsLabel = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // SPort
            // 
            this.SPort.BaudRate = 4800;
            this.SPort.StopBits = System.IO.Ports.StopBits.Two;
            this.SPort.DataReceived += new System.IO.Ports.SerialDataReceivedEventHandler(this.SPort_DataReceived);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(75, 38);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(66, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Votalje leído";
            // 
            // VoltsLabel
            // 
            this.VoltsLabel.AutoSize = true;
            this.VoltsLabel.Location = new System.Drawing.Point(86, 82);
            this.VoltsLabel.Name = "VoltsLabel";
            this.VoltsLabel.Size = new System.Drawing.Size(43, 13);
            this.VoltsLabel.TabIndex = 1;
            this.VoltsLabel.Text = "------------";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(212, 160);
            this.Controls.Add(this.VoltsLabel);
            this.Controls.Add(this.label1);
            this.MaximumSize = new System.Drawing.Size(228, 199);
            this.MinimumSize = new System.Drawing.Size(228, 199);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.IO.Ports.SerialPort SPort;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label VoltsLabel;
    }
}

