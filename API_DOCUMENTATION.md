# Gym Management System API Documentation

Base URL: `http://localhost:5000`  
Port: `process.env.PORT` or `5000`

No query parameters are used in the current implementation.

JWT payload fields: `id`, `email`, `role`  
JWT expiry: `process.env.JWT_EXPIRES_IN` or `7d`

## Common Auth Middleware Errors

These can occur on any API that uses `authMiddleware`.

error = 401
{
    "success": false,
    "message": "Authorization token is required"
}

## API Summary

| # | Method | API | Role | Auth |
|---|---|---|---|---|
| 1 | POST | /api/contact | PUBLIC | No |
| 2 | POST | /api/member/auth/register | MEMBER | No |
| 3 | POST | /api/member/auth/login | MEMBER | No |
| 4 | GET | /api/member/auth/profile | MEMBER | JWT |
| 5 | GET | /api/member/exercises | MEMBER | JWT |
| 6 | GET | /api/member/challenges | MEMBER | JWT |
| 7 | POST | /api/member/progress | MEMBER | JWT |
| 8 | GET | /api/member/progress | MEMBER | JWT |
| 9 | GET | /api/member/progress/:id | MEMBER | JWT |
| 10 | PUT | /api/member/progress/:id | MEMBER | JWT |
| 11 | DELETE | /api/member/progress/:id | MEMBER | JWT |
| 12 | POST | /api/member/profile | MEMBER | JWT |
| 13 | GET | /api/member/profile | MEMBER | JWT |
| 14 | PUT | /api/member/profile | MEMBER | JWT |
| 15 | GET | /api/member/notifications | MEMBER | JWT |
| 16 | PUT | /api/member/notifications/:id/read | MEMBER | JWT |
| 17 | GET | /api/member/class-schedules | MEMBER | JWT |
| 18 | GET | /api/member/class-schedules/:id | MEMBER | JWT |
| 19 | GET | /api/member/workout-plans | MEMBER | JWT |
| 20 | GET | /api/member/workout-plans/:id | MEMBER | JWT |
| 21 | POST | /api/member/workout-plans/:planId/exercises/:workoutExerciseId/complete | MEMBER | JWT |
| 22 | GET | /api/member/diet-plans | MEMBER | JWT |
| 23 | GET | /api/member/diet-plans/:id | MEMBER | JWT |
| 24 | GET | /api/member/diet-plans/today | MEMBER | JWT |
| 25 | GET | /api/member/messages/trainer | MEMBER | JWT |
| 26 | GET | /api/member/messages/:trainerId | MEMBER | JWT |
| 27 | POST | /api/member/messages/:trainerId | MEMBER | JWT |
| 28 | PUT | /api/member/messages/:id/read | MEMBER | JWT |
| 29 | GET | /api/member/dashboard/checkin-days | MEMBER | JWT |
| 30 | GET | /api/member/dashboard/cheat-count | MEMBER | JWT |
| 31 | GET | /api/member/dashboard/diet-plan | MEMBER | JWT |
| 32 | GET | /api/member/dashboard/workout-plans | MEMBER | JWT |
| 33 | GET | /api/member/dashboard/notifications | MEMBER | JWT |
| 34 | GET | /api/member/dashboard/previous-month-progress | MEMBER | JWT |
| 35 | GET | /api/member/dashboard/today-workout | MEMBER | JWT |
| 36 | POST | /api/member/cheat-days | MEMBER | JWT |
| 37 | GET | /api/member/cheat-days | MEMBER | JWT |
| 38 | GET | /api/member/cheat-days/:id | MEMBER | JWT |
| 39 | PUT | /api/member/cheat-days/:id | MEMBER | JWT |
| 40 | DELETE | /api/member/cheat-days/:id | MEMBER | JWT |
| 41 | POST | /api/trainer/auth/login | TRAINER | No |
| 42 | GET | /api/trainer/auth/profile | TRAINER | JWT |
| 43 | GET | /api/trainer/assigned-members | TRAINER | JWT |
| 44 | GET | /api/trainer/assigned-members/:id | TRAINER | JWT |
| 45 | POST | /api/trainer/class-schedules | TRAINER | JWT |
| 46 | GET | /api/trainer/class-schedules | TRAINER | JWT |
| 47 | GET | /api/trainer/class-schedules/:id | TRAINER | JWT |
| 48 | PUT | /api/trainer/class-schedules/:id | TRAINER | JWT |
| 49 | DELETE | /api/trainer/class-schedules/:id | TRAINER | JWT |
| 50 | POST | /api/trainer/workout-plans | TRAINER | JWT |
| 51 | GET | /api/trainer/workout-plans | TRAINER | JWT |
| 52 | GET | /api/trainer/workout-plans/:id | TRAINER | JWT |
| 53 | PUT | /api/trainer/workout-plans/:id | TRAINER | JWT |
| 54 | DELETE | /api/trainer/workout-plans/:id | TRAINER | JWT |
| 55 | POST | /api/trainer/workout-plans/:id/exercises | TRAINER | JWT |
| 56 | PUT | /api/trainer/workout-plans/:planId/exercises/:workoutExerciseId | TRAINER | JWT |
| 57 | DELETE | /api/trainer/workout-plans/:planId/exercises/:workoutExerciseId | TRAINER | JWT |
| 58 | POST | /api/trainer/diet-plans | TRAINER | JWT |
| 59 | GET | /api/trainer/diet-plans | TRAINER | JWT |
| 60 | GET | /api/trainer/diet-plans/:id | TRAINER | JWT |
| 61 | PUT | /api/trainer/diet-plans/:id | TRAINER | JWT |
| 62 | DELETE | /api/trainer/diet-plans/:id | TRAINER | JWT |
| 63 | GET | /api/trainer/messages | TRAINER | JWT |
| 64 | GET | /api/trainer/messages/:memberId | TRAINER | JWT |
| 65 | POST | /api/trainer/messages/:memberId | TRAINER | JWT |
| 66 | PUT | /api/trainer/messages/:id/read | TRAINER | JWT |
| 67 | GET | /api/trainer/dashboard/assigned-members | TRAINER | JWT |
| 68 | GET | /api/trainer/dashboard/diet-plans | TRAINER | JWT |
| 69 | GET | /api/trainer/dashboard/workout-plans | TRAINER | JWT |
| 70 | GET | /api/trainer/dashboard/check-ins | TRAINER | JWT |
| 71 | GET | /api/trainer/cheat-days/members | TRAINER | JWT |
| 72 | GET | /api/trainer/cheat-days/current-month | TRAINER | JWT |
| 73 | GET | /api/trainer/cheat-days/previous-month | TRAINER | JWT |
| 74 | GET | /api/trainer/cheat-days/members/:memberId | TRAINER | JWT |
| 75 | GET | /api/trainer/cheat-days/members/:memberId/:id | TRAINER | JWT |
| 76-130 | Admin APIs | /api/admin/* | ADMIN | JWT/No |
| - | Fees | /api/admin/fees, /api/member/fees/* | ADMIN/MEMBER | JWT |
| - | Analytics | /api/member/analytics/*, /api/trainer/analytics/* | MEMBER/TRAINER | JWT |
| - | Public | /api/trainers, /api/content, /api/promotions, /api/plans | PUBLIC | No |

