import nodemailer from "nodemailer";

const sendEmail = async (options) => {
  try {
    // Create a transporter
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.mailtrap.io',
      port: process.env.SMTP_PORT || 2525,
      auth: {
        user: process.env.SMTP_USER || 'your_mailtrap_username',
        pass: process.env.SMTP_PASS || 'your_mailtrap_password'
      }
    });

    // Define email options
    const mailOptions = {
      from: process.env.SMTP_FROM || 'noreply@yoursystem.com',
      to: options.email,
      subject: options.subject,
      html: options.message
    };

    // Send email
    await transporter.sendMail(mailOptions);
    console.log(`Email sent to ${options.email}`);
    return true;
  } catch (error) {
    // Log error but don't throw it - this allows registration to continue
    console.error('Email sending failed:', error);
    return false;
  }
};
