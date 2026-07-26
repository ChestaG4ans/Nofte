from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import SecurityService
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.auth_schema import LoginRequest, RegisterRequest


class AuthService:
    def __init__(self, db: Session, security_service: SecurityService):
        self.db = db
        self.security_service = security_service
        self.user_repository = UserRepository(db)

    def register(self, payload: RegisterRequest) -> User:
        existing_user = self.user_repository.get_by_email(payload.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email sudah terdaftar."
            )

        hashed_password = self.security_service.hash_password(payload.password)
        return self.user_repository.create(
            name=payload.name,
            email=payload.email,
            hashed_password=hashed_password
        )

    def login(self, payload: LoginRequest) -> dict:
        user = self.user_repository.get_by_email(payload.email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email atau password salah."
            )

        if not self.security_service.verify_password(
            payload.password,
            user.hashed_password
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email atau password salah."
            )

        access_token = self.security_service.create_access_token({"sub": str(user.id)})
        return {"access_token": access_token, "token_type": "bearer"}
