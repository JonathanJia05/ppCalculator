import os
import smtplib
from email.message import EmailMessage
from fastapi import FastAPI
from dotenv import load_dotenv
from app.models.feedback import Feedback

load_dotenv()

app = FastAPI()


def send_feedback_email(feedback: Feedback):
    msg = EmailMessage()
    msg["Subject"] = f"Feedback from {feedback.name}: {feedback.subject}"
    msg["From"] = os.getenv("EMAIL_FROM")
    msg["To"] = os.getenv("EMAIL_TO")
    msg.set_content(
        f"Name: {feedback.name}\n"
        f"Email: {feedback.email}\n\n"
        f"Message:\n{feedback.message}"
    )

    smtp_server = os.getenv("SMTP_SERVER")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER")
    smtp_password = os.getenv("SMTP_PASSWORD")

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.send_message(msg)
            print("Feedback email sent successfully.")
    except Exception as e:
        print(f"Error sending feedback email: {e}")
        raise
